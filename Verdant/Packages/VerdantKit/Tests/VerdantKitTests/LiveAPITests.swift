import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import VerdantKit

/// Set VERDANT_API_URL (for example http://localhost:8080/verdant/v1/) to run these
/// tests against the demonstration server of the companion repository.
let liveBaseURL = ProcessInfo.processInfo.environment["VERDANT_API_URL"].flatMap(URL.init(string:))

// <livetests>
@Suite("Live API", .enabled(if: liveBaseURL != nil, "VERDANT_API_URL is not set"))
struct LiveAPITests {
    let client = APIClient(configuration: APIConfiguration(baseURL: liveBaseURL!))

    @Test func catalogueIsPaginated() async throws {
        let service = RemoteSpeciesService(client: client)
        let first = try await service.species(page: 1, perPage: 20)
        let second = try await service.species(page: 2, perPage: 20)
        #expect(first.total == 48 && first.totalPages == 3)
        #expect(Set(first.items.map(\.id)).isDisjoint(with: second.items.map(\.id)))
    }

    @Test func signInBackUpAndRestore() async throws {
        let auth = AuthService(client: client)
        let session = try await auth.signIn(email: "demo@verdant.example",
                                            password: "local-only-demo-password")
        let authenticator = Authenticator(store: InMemoryTokenStore(session: session)) { token in
            try await auth.refresh(refreshToken: token)
        }
        let backup = RemoteBackupService(client: APIClient(configuration: client.configuration,
                                                           authenticator: authenticator))
        // Whole seconds: ISO 8601 dates in JSON do not keep fractions of a second.
        let now = Date(timeIntervalSince1970: Date.now.timeIntervalSince1970.rounded(.down))
        let plants = SampleData.garden(reference: now)
        let receipt = try await backup.upload(plants)
        #expect(receipt.plantCount == plants.count)
        #expect(try await backup.download() == plants)
    }

    @Test func wrongPasswordIsRejected() async {
        await #expect(throws: APIError.unauthorized) {
            try await AuthService(client: client).signIn(email: "demo@verdant.example",
                                                         password: "not-the-password")
        }
    }
}
// </livetests>
