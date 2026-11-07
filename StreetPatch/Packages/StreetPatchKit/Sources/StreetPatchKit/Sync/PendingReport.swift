import Foundation

// <pending>
/// A report waiting in the outbox. Its id doubles as the Idempotency-Key, so
/// sending it twice (after a lost response, a crash, a relaunch) creates it once.
public struct PendingReport: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var draft: ReportDraft
    public var photo: Data?  // JPEG, already compressed
    public let queuedAt: Date
    public var serverID: String?  // set once the server has created the report
    public var failure: String?  // set when the server refused it for good

    public init(id: UUID = UUID(), draft: ReportDraft, photo: Data?, queuedAt: Date) {
        self.id = id
        self.draft = draft
        self.photo = photo
        self.queuedAt = queuedAt
    }

    public var needsAttention: Bool { failure != nil }
}

/// Where the outbox is kept between launches.
public protocol OutboxStorage: Sendable {
    func load() async -> [PendingReport]
    func save(_ items: [PendingReport]) async
}

public actor InMemoryOutboxStorage: OutboxStorage {
    private var items: [PendingReport]
    public init(_ items: [PendingReport] = []) { self.items = items }
    public func load() -> [PendingReport] { items }
    public func save(_ items: [PendingReport]) { self.items = items }
}

/// A JSON file in Application Support. Photos travel inside it as Base64: the
/// outbox holds a few reports at most, so one small file stays simple and atomic.
public actor JSONFileOutboxStorage: OutboxStorage {
    private let url: URL

    public init(url: URL) { self.url = url }

    public static func defaultURL() throws -> URL {
        let folder = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true)
        return folder.appendingPathComponent("outbox.json")
    }

    public func load() -> [PendingReport] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? APIClient.makeDecoder().decode([PendingReport].self, from: data)) ?? []
    }

    public func save(_ items: [PendingReport]) {
        do {
            let data = try APIClient.makeEncoder().encode(items)
            #if os(iOS)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            #else
            try data.write(to: url, options: .atomic)
            #endif
        } catch {
            // Losing the outbox would lose reports: surface it in development.
            assertionFailure("Could not save the outbox: \(error)")
        }
    }
}
// </pending>
