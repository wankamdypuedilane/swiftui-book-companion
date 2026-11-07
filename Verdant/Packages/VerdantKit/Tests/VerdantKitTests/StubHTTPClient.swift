import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import VerdantKit

// <stub>
/// An HTTPClient that answers from a script of prepared responses and records
/// the requests it receives.
actor StubHTTPClient: HTTPClient {
    enum Reply {
        case json(Int, String)            // status code and body
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
            let response = HTTPURLResponse(url: request.url!, statusCode: status,
                                           httpVersion: "HTTP/1.1", headerFields: nil)!
            return (Data(body.utf8), response)
        }
    }
}
// </stub>

let testBaseURL = URL(string: "https://api.verdant.example/verdant/v1/")!

func makeClient(_ stub: StubHTTPClient, authenticator: Authenticator? = nil) -> APIClient {
    APIClient(configuration: APIConfiguration(baseURL: testBaseURL, maxAttempts: 3,
                                              retryDelay: .milliseconds(1)),
              http: stub, authenticator: authenticator)
}

let pageJSON = """
{"items":[{"id":"aloe-vera","commonName":"Aloe","scientificName":"Aloe vera",
"family":"Asphodelaceae","light":"bright","wateringDays":21,"difficulty":"easy",
"petSafe":false,"summary":"A succulent.","symbolName":"leaf"}],
"page":1,"perPage":1,"total":2,"totalPages":2}
"""
