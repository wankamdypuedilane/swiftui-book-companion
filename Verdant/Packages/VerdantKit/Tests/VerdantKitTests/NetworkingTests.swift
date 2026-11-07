import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import VerdantKit

// <nettests>
@Suite("Networking")
struct NetworkingTests {
    @Test func decodesAPageAndBuildsTheQuery() async throws {
        let stub = StubHTTPClient([.json(200, pageJSON)])
        let service = RemoteSpeciesService(client: makeClient(stub))
        let page = try await service.species(page: 1, perPage: 1, query: "aloe", light: .bright)
        #expect(page.items.map(\.commonName) == ["Aloe"])
        #expect(page.hasMore)
        let url = try #require(await stub.requests.first?.url?.absoluteString)
        #expect(url == "https://api.verdant.example/verdant/v1/species?page=1&perPage=1&q=aloe&light=bright")
    }

    @Test func serverErrorMessagesAreKept() async {
        let stub = StubHTTPClient([.json(404, #"{"error":"Unknown species."}"#)])
        let service = RemoteSpeciesService(client: makeClient(stub))
        await #expect(throws: APIError.http(status: 404, message: "Unknown species.")) {
            try await service.species(id: "unicorn-plant")
        }
    }

    @Test func transientFailuresAreRetried() async throws {
        let stub = StubHTTPClient([.json(503, "{}"), .failure(.timedOut), .json(200, pageJSON)])
        let page = try await RemoteSpeciesService(client: makeClient(stub)).species(page: 1)
        #expect(page.items.count == 1)
        #expect(await stub.requests.count == 3)
    }

    @Test func clientErrorsAreNotRetried() async {
        let stub = StubHTTPClient([.json(400, #"{"error":"Bad page."}"#), .json(200, pageJSON)])
        await #expect(throws: APIError.self) {
            try await RemoteSpeciesService(client: makeClient(stub)).species(page: -1)
        }
        #expect(await stub.requests.count == 1)
    }

    @Test func offlineIsRecognized() async {
        let stub = StubHTTPClient([.failure(.notConnectedToInternet)])
        let client = APIClient(configuration: .init(baseURL: testBaseURL, maxAttempts: 1),
                               http: stub)
        await #expect(throws: APIError.offline) {
            try await RemoteSpeciesService(client: client).species(page: 1)
        }
    }

    @Test func malformedJSONIsADecodingError() async {
        let stub = StubHTTPClient([.json(200, #"{"items": "oops"}"#)])
        do {
            _ = try await RemoteSpeciesService(client: makeClient(stub)).species(page: 1)
            Issue.record("Expected a decoding error")
        } catch {
            guard case .decoding = error else { Issue.record("Got \(error)"); return }
        }
    }
}
// </nettests>

// <authtests>
@Suite("Authentication")
struct AuthenticationTests {
    let expired = AuthSession(email: "demo@verdant.example", accessToken: "old",
                              refreshToken: "r1", expiresAt: .distantPast)

    @Test func expiredTokensAreRefreshedOnceForConcurrentCallers() async throws {
        let counter = Counter()
        let authenticator = Authenticator(store: InMemoryTokenStore(session: expired)) { _ in
            await counter.increment()
            try? await Task.sleep(for: .milliseconds(50))       // a slow refresh
            return AuthSession(email: "demo@verdant.example", accessToken: "new",
                               refreshToken: "r2", expiresAt: .now.addingTimeInterval(900))
        }
        async let a = authenticator.validAccessToken()
        async let b = authenticator.validAccessToken()
        async let c = authenticator.validAccessToken()
        let tokens = try await [a, b, c]
        #expect(tokens == ["new", "new", "new"])
        #expect(await counter.value == 1)
    }

    @Test func authenticatedRequestsCarryTheBearerToken() async throws {
        let valid = AuthSession(email: "demo@verdant.example", accessToken: "abc",
                                refreshToken: "r", expiresAt: .now.addingTimeInterval(900))
        let authenticator = Authenticator(store: InMemoryTokenStore(session: valid)) { _ in valid }
        let stub = StubHTTPClient([.json(200, "[]")])
        let plants = try await RemoteBackupService(client: makeClient(stub, authenticator: authenticator))
            .download()
        #expect(plants.isEmpty)
        let header = await stub.requests.first?.value(forHTTPHeaderField: "Authorization")
        #expect(header == "Bearer abc")
    }

    @Test func signedOutUsersGetUnauthorized() async {
        let authenticator = Authenticator(store: InMemoryTokenStore()) { _ in
            throw APIError.unauthorized
        }
        let stub = StubHTTPClient([])
        await #expect(throws: APIError.unauthorized) {
            try await RemoteBackupService(client: makeClient(stub, authenticator: authenticator))
                .download()
        }
        #expect(await stub.requests.isEmpty)               // no request was even sent
    }
}

actor Counter {
    private(set) var value = 0
    func increment() { value += 1 }
}
// </authtests>

// <repotests>
@MainActor
@Suite("Repository and catalogue")
struct RepositoryTests {
    @Test func cachedPagesAreUsedWhenOffline() async throws {
        let stub = StubHTTPClient([.json(200, pageJSON), .failure(.notConnectedToInternet)])
        let client = APIClient(configuration: .init(baseURL: testBaseURL, maxAttempts: 1), http: stub)
        let repository = SpeciesRepository(service: RemoteSpeciesService(client: client),
                                           cache: MemorySpeciesCache())
        let online = try await repository.page(1, query: nil, light: nil)
        let offline = try await repository.page(1, query: nil, light: nil)
        #expect(!online.isFromCache)
        #expect(offline.isFromCache)
        #expect(offline.page.items == online.page.items)
    }

    @Test func catalogueLoadsTheNextPageAtTheEnd() async throws {
        let second = pageJSON.replacingOccurrences(of: "aloe-vera", with: "aloe-2")
            .replacingOccurrences(of: #""page":1"#, with: #""page":2"#)
        let stub = StubHTTPClient([.json(200, pageJSON), .json(200, second)])
        let repository = SpeciesRepository(service: RemoteSpeciesService(client: makeClient(stub)),
                                           cache: MemorySpeciesCache())
        let model = CatalogModel(repository: repository)
        await model.reload()
        #expect(model.phase == .loaded)
        #expect(model.canLoadMore)
        await model.loadMoreIfNeeded(after: try #require(model.species.last))
        #expect(model.species.map(\.id) == ["aloe-vera", "aloe-2"])
        #expect(!model.canLoadMore)
    }

    @Test func catalogueReportsFailures() async {
        let stub = StubHTTPClient([.json(500, "{}"), .json(500, "{}"), .json(500, "{}")])
        let repository = SpeciesRepository(service: RemoteSpeciesService(client: makeClient(stub)),
                                           cache: MemorySpeciesCache())
        let model = CatalogModel(repository: repository)
        await model.reload()
        #expect(model.phase == .failed(.http(status: 500, message: nil)))
    }
}
// </repotests>
