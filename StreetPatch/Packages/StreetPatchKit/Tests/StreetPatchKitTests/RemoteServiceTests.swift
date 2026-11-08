import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import StreetPatchKit

let reportJSON = """
    {"id":"KB-0009","title":"Broken bench in the square","details":"","category":"other",
    "status":"submitted","latitude":48.3901,"longitude":-4.485,
    "createdAt":"2026-11-07T10:00:00Z","updatedAt":"2026-11-07T10:00:00Z",
    "supportCount":0,"supportedByMe":false,"isMine":true,"hasPhoto":false,
    "history":[{"status":"submitted","at":"2026-11-07T10:00:00Z","note":null}]}
    """

func signedInAuthenticator() -> Authenticator {
    let session = AuthSession(
        email: "resident@streetpatch.example", accessToken: "token-1",
        refreshToken: "refresh-1", expiresAt: .distantFuture)
    return Authenticator(store: InMemoryTokenStore(session: session)) { _ in
        throw APIError.unauthorized
    }
}

// <remotetests>
@Suite("Remote service")
struct RemoteServiceTests {
    @Test func createSendsTheKeyAndRetriesWithTheSameOne() async throws {
        let stub = StubHTTPClient([.json(503, #"{"error":"Busy."}"#), .json(201, reportJSON)])
        let service = RemoteReportsService(
            client: makeClient(stub, authenticator: signedInAuthenticator()))
        let key = UUID()
        let report = try await service.create(validDraft, idempotencyKey: key)
        #expect(report.id == "KB-0009")

        let requests = await stub.requests
        #expect(requests.count == 2)  // the 503 was retried...
        let keys = requests.map { $0.value(forHTTPHeaderField: "Idempotency-Key") }
        #expect(keys == [key.uuidString, key.uuidString])  // ...with the same key
        #expect(requests[0].value(forHTTPHeaderField: "Authorization") == "Bearer token-1")
        let body =
            try JSONSerialization.jsonObject(with: requests[0].httpBody!) as? [String: Any]
        #expect(body?["title"] as? String == validDraft.title)
        #expect(body?["category"] as? String == "other")
    }

    @Test func photosAreSentAsJPEG() async throws {
        let stub = StubHTTPClient([.json(204, "")])
        let service = RemoteReportsService(
            client: makeClient(stub, authenticator: signedInAuthenticator()))
        try await service.uploadPhoto(Data([0xFF, 0xD8]), for: "KB-0009")
        let request = try #require(await stub.requests.first)
        #expect(request.httpMethod == "PUT")
        #expect(request.url?.path.hasSuffix("/reports/KB-0009/photo") == true)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "image/jpeg")
    }

    @Test func publicReadsSendTheTokenOnlyWhenSignedIn() async throws {
        let signedIn = StubHTTPClient([.json(200, reportJSON)])
        _ = try await RemoteReportsService(
            client: makeClient(signedIn, authenticator: signedInAuthenticator())
        ).report(id: "KB-0009")
        let signedOut = StubHTTPClient([.json(200, reportJSON)])
        _ = try await RemoteReportsService(client: makeClient(signedOut)).report(id: "KB-0009")
        let withToken = await signedIn.requests.first?.value(
            forHTTPHeaderField: "Authorization")
        let without = await signedOut.requests.first?.value(forHTTPHeaderField: "Authorization")
        #expect(withToken == "Bearer token-1")  // so that isMine is right
        #expect(without == nil)
    }

    @Test func validationErrorsCarryTheServerMessage() async {
        let stub = StubHTTPClient([
            .json(422, #"{"error":"This place is outside Kerbrume.","field":"location"}"#)
        ])
        let service = RemoteReportsService(
            client: makeClient(stub, authenticator: signedInAuthenticator()))
        await #expect(
            throws: APIError.http(status: 422, message: "This place is outside Kerbrume.")
        ) {
            try await service.create(validDraft, idempotencyKey: UUID())
        }
    }
}
// </remotetests>
