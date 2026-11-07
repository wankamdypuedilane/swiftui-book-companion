import Foundation

// <session>
/// The tokens returned by the sign-in endpoint.
public struct AuthSession: Codable, Equatable, Sendable {
    public var email: String
    public var accessToken: String
    public var refreshToken: String
    public var expiresAt: Date

    public init(email: String, accessToken: String, refreshToken: String, expiresAt: Date) {
        self.email = email
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }
}

/// Where the session is kept between launches. The app uses the Keychain.
public protocol TokenStore: Sendable {
    func load() async -> AuthSession?
    func save(_ session: AuthSession?) async
}

public actor InMemoryTokenStore: TokenStore {
    private var session: AuthSession?
    public init(session: AuthSession? = nil) { self.session = session }
    public func load() async -> AuthSession? { session }
    public func save(_ session: AuthSession?) async { self.session = session }
}
// </session>

// <authenticator>
/// Hands out a valid access token, refreshing it when it is about to expire.
/// As an actor it serializes access to the session, and concurrent callers share
/// a single refresh instead of sending one each.
public actor Authenticator {
    /// Exchanges a refresh token for a new session. Errors other than APIError are
    /// reported as transport errors.
    public typealias Refresher = @Sendable (String) async throws -> AuthSession

    private let store: any TokenStore
    private let refresher: Refresher
    private let now: @Sendable () -> Date
    private var refreshTask: Task<AuthSession, any Error>?

    public init(
        store: any TokenStore, now: @escaping @Sendable () -> Date = { .now },
        refresher: @escaping Refresher
    ) {
        self.store = store
        self.now = now
        self.refresher = refresher
    }

    public func validAccessToken() async throws(APIError) -> String {
        guard let session = await store.load() else { throw .unauthorized }
        if session.expiresAt.timeIntervalSince(now()) > 60 { return session.accessToken }
        return try await refreshed(from: session).accessToken
    }

    /// Forces the next call to refresh, after the server rejected the token.
    public func invalidateAccessToken() async {
        guard var session = await store.load() else { return }
        session.expiresAt = .distantPast
        await store.save(session)
    }

    public func signIn(with session: AuthSession) async { await store.save(session) }
    public func signOut() async { await store.save(nil) }
    public var currentSession: AuthSession? { get async { await store.load() } }

    private func refreshed(from session: AuthSession) async throws(APIError) -> AuthSession {
        if let refreshTask {  // a refresh is already running: wait for it
            return try await Self.value(of: refreshTask)
        }
        let task = Task { [refresher] () async throws -> AuthSession in
            try await refresher(session.refreshToken)
        }
        refreshTask = task
        defer { refreshTask = nil }
        do {
            let newSession = try await Self.value(of: task)
            await store.save(newSession)
            return newSession
        } catch {
            if error == .unauthorized { await store.save(nil) }  // refresh token rejected
            throw error
        }
    }

    private static func value(
        of task: Task<AuthSession, any Error>
    ) async throws(APIError) -> AuthSession {
        do { return try await task.value } catch {
            throw (error as? APIError) ?? .transport("\(error)")
        }
    }
}
// </authenticator>
