import Foundation

// <outbox>
/// Reports are never sent directly: they go into this outbox, which is saved to
/// disk first and sent when the network allows. The resident can write a report
/// in a basement car park and it leaves when they walk out.
public actor ReportOutbox {
    public struct FlushResult: Equatable, Sendable {
        public var sent: [UUID: Report] = [:]  // keyed by PendingReport.id
        public var refused = 0  // the server rejected them; the resident must act
        public var waiting = 0  // still queued, to try again later
    }

    private let storage: any OutboxStorage
    private let service: any ReportsService
    private let now: @Sendable () -> Date
    private var items: [PendingReport]?  // nil until loaded from storage
    private var running: Task<FlushResult, Never>?

    public init(
        storage: any OutboxStorage, service: any ReportsService,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.storage = storage
        self.service = service
        self.now = now
    }

    public var pending: [PendingReport] {
        get async { await loaded() }
    }

    @discardableResult
    public func enqueue(_ draft: ReportDraft, photo: Data?) async -> PendingReport {
        let item = PendingReport(draft: draft, photo: photo, queuedAt: now())
        await change { $0.append(item) }
        return item
    }

    public func discard(_ id: UUID) async {
        await change { $0.removeAll { $0.id == id } }
    }

    /// Replaces the draft of a refused item and queues it again with a new key.
    public func retry(_ id: UUID, with draft: ReportDraft) async {
        await change { all in
            guard let index = all.firstIndex(where: { $0.id == id }) else { return }
            let old = all[index]
            all[index] = PendingReport(draft: draft, photo: old.photo, queuedAt: old.queuedAt)
        }
    }

    /// Sends what can be sent, oldest first. Concurrent calls (a network change and a
    /// pull to refresh at the same moment) share one pass instead of racing.
    @discardableResult
    public func flush() async -> FlushResult {
        if let running { return await running.value }
        let task = Task { await self.sendAll() }
        running = task
        defer { running = nil }
        return await task.value
    }

    /// Works item by item on the stored queue, never on a copy: a report queued or
    /// discarded while a request is in flight is not overwritten by this pass.
    private func sendAll() async -> FlushResult {
        var result = FlushResult()
        var done: Set<UUID> = []  // sent, refused or skipped during this pass
        while let item = await loaded().first(where: { !done.contains($0.id) }) {
            done.insert(item.id)
            if item.needsAttention {
                result.refused += 1
                continue
            }
            switch await send(item) {
            case .sent(let report):
                result.sent[item.id] = report
                await change { $0.removeAll { $0.id == item.id } }
            case .refused(let message):
                await change(item.id) { $0.failure = message }
                result.refused += 1
            case .later:
                // Offline or signed out: the rest would fail the same way.
                let rest = await loaded().filter { $0.id == item.id || !done.contains($0.id) }
                result.waiting = rest.count { !$0.needsAttention }
                result.refused += rest.count { $0.needsAttention }
                return result
            }
        }
        return result
    }

    private enum Outcome { case sent(Report), refused(String), later }

    private func send(_ item: PendingReport) async -> Outcome {
        do {
            var report: Report
            if let serverID = item.serverID {
                report = try await service.report(id: serverID)
            } else {
                report = try await service.create(item.draft, idempotencyKey: item.id)
                let serverID = report.id
                // Saved before the next request: a relaunch will not create it again.
                await change(item.id) { $0.serverID = serverID }
            }
            if let photo = item.photo {
                do {
                    try await service.uploadPhoto(photo, for: report.id)
                    report.hasPhoto = true
                } catch  where !Self.isTemporary(error) {
                    // The report exists; only the photo was refused. Keep the report.
                }
            }
            return .sent(report)
        } catch {
            return Self.isTemporary(error) ? .later : .refused(error.userMessage)
        }
    }

    /// Failures that a later attempt may not repeat.
    private static func isTemporary(_ error: APIError) -> Bool {
        error.isRetryable || error == .unauthorized || error == .cancelled
    }

    private func loaded() async -> [PendingReport] {
        if let items { return items }
        let stored = await storage.load()
        if let items { return items }  // another call loaded it while this one waited
        items = stored
        return stored
    }

    /// Reads, changes and stores the queue with no suspension in between, so that
    /// concurrent calls on the actor cannot interleave inside the change.
    private func change(_ modify: (inout [PendingReport]) -> Void) async {
        var all = await loaded()
        modify(&all)
        items = all
        await storage.save(all)
    }

    private func change(_ id: UUID, _ modify: (inout PendingReport) -> Void) async {
        await change { all in
            if let index = all.firstIndex(where: { $0.id == id }) { modify(&all[index]) }
        }
    }
}
// </outbox>
