import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import StreetPatchKit

// <stub>
/// An HTTPClient that answers from a script of prepared responses and records
/// the requests it receives.
actor StubHTTPClient: HTTPClient {
    enum Reply {
        case json(Int, String)  // status code and body
        case failure(URLError.Code)
    }

    private var replies: [Reply]
    private(set) var requests: [URLRequest] = []

    init(_ replies: [Reply]) { self.replies = replies }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        guard !replies.isEmpty else { throw URLError(.badServerResponse) }
        switch replies.removeFirst() {
        case .failure(let code):
            throw URLError(code)
        case .json(let status, let body):
            let response = HTTPURLResponse(
                url: request.url!, statusCode: status,
                httpVersion: "HTTP/1.1", headerFields: nil)!
            return (Data(body.utf8), response)
        }
    }
}
// </stub>

let testBaseURL = URL(string: "https://api.streetpatch.example/streetpatch/v1/")!

func makeClient(_ stub: StubHTTPClient, authenticator: Authenticator? = nil) -> APIClient {
    APIClient(
        configuration: APIConfiguration(
            baseURL: testBaseURL, maxAttempts: 3, retryDelay: .milliseconds(1)),
        http: stub, authenticator: authenticator)
}
