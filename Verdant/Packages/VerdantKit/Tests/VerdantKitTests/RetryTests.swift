import Foundation
import Testing
@testable import VerdantKit

// <retry429>
@Test func tooManyRequestsIsRetried() async throws {
    let stub = StubHTTPClient([.json(429, #"{"error":"Slow down."}"#), .json(200, pageJSON)])
    let page = try await RemoteSpeciesService(client: makeClient(stub)).species(page: 1)
    #expect(page.items.count == 1)
    #expect(await stub.requests.count == 2)
}
// </retry429>
