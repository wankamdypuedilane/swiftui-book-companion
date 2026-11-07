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
        var all = await loaded()
        all.append(item)
        await update(all)
        return item
    }

    public func discard(_ id: UUID) async {
        await update(await loaded().filter { $0.id != id })
    }

    /// Replaces the draft of a refused item and queues it again with a new key.
    public func retry(_ id: UUID, with draft: ReportDraft) async {
        var all = await loaded()
        guard let index = all.firstIndex(where: { $0.id == id }) else { return }
        let old = all[index]
        all[index] = PendingReport(draft: draft, photo: old.photo, queuedAt: old.queuedAt)
        await update(all)
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

    private func sendAll() async -> FlushResult {
        var result = FlushResult()
        var all = await loaded()
        var index = 0
        while index < all.count {
            if all[index].needsAttention {
                result.refused += 1
                index += 1
                continue
            }
            switch await send(&all[index]) {
            case .sent(let report):
                result.sent[all[index].id] = report
                all.remove(at: index)
                await update(all)
            case .refused(let message):
                all[index].failure = message
                await update(all)
                result.refused += 1
                index += 1
            case .later:
                await update(all)  // keep the serverID if the report itself got through
                result.waiting = all[index...].count { !$0.needsAttention }
                result.refused += all[index...].count { $0.needsAttention }
                return result  // offline or signed out: the rest would fail the same way
            }
        }
        return result
    }

    private enum Outcome { case sent(Report), refused(String), later }

    private func send(_ item: inout PendingReport) async -> Outcome {
        do {
            var report: Report
            if let serverID = item.serverID {
                report = try await service.report(id: serverID)
            } else {
                report = try await service.create(item.draft, idempotencyKey: item.id)
                item.serverID = report.id
            }
            if let photo = item.photo {
                do {
                    try await service.uploadPhoto(photo, for: report.id)
                    report.hasPhoto = true
                } catch  where !Self.isTemporary(error) {
                    // The report exists; only the photo was refused. Keep the report.
                }
                item.photo = nil
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

    private func update(_ all: [PendingReport]) async {
        items = all
        await storage.save(all)
    }
}
// </outbox>
