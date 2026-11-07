import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import StreetPatchKit

/// Set STREETPATCH_API_URL (for example http://localhost:8080/streetpatch/v1/) to run
/// these tests against the demonstration server of the companion repository.
let liveBaseURL = ProcessInfo.processInfo.environment["STREETPATCH_API_URL"].flatMap(
    URL.init(string:))

// <livetests>
@Suite("Live API", .enabled(if: liveBaseURL != nil, "STREETPATCH_API_URL is not set"))
struct LiveAPITests {
    let client = APIClient(configuration: APIConfiguration(baseURL: liveBaseURL!))

    func signedInService() async throws -> RemoteReportsService {
        let auth = AuthService(client: client)
        let session = try await auth.signIn(
            email: "resident@streetpatch.example", password: "local-only-demo-password")
        let authenticator = Authenticator(store: InMemoryTokenStore(session: session)) {
            token in try await auth.refresh(refreshToken: token)
        }
        return RemoteReportsService(
            client: APIClient(configuration: client.configuration, authenticator: authenticator)
        )
    }

    @Test func publicListIsReadableWithoutAnAccount() async throws {
        let page = try await RemoteReportsService(client: client).reports(.open, page: 1)
        #expect(!page.items.isEmpty)
        #expect(page.items.allSatisfy { $0.status.isOpen })
    }

    @Test func outboxSendsAReportWithItsPhotoOnce() async throws {
        let service = try await signedInService()
        let outbox = ReportOutbox(storage: InMemoryOutboxStorage(), service: service)
        let item = await outbox.enqueue(validDraft, photo: Data([0xFF, 0xD8, 0xFF, 0xE0]))
        let report = try #require(await outbox.flush().sent[item.id])
        #expect(report.isMine && report.hasPhoto)

        // Replaying the same key returns the same report.
        let replay = try await service.create(validDraft, idempotencyKey: item.id)
        #expect(replay.id == report.id)

        try await service.withdraw(id: report.id)
        await #expect(throws: APIError.http(status: 404, message: "Unknown report.")) {
            try await service.report(id: report.id)
        }
    }
}
// </livetests>
