import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking        // URLSession lives here on Linux
#endif

// <client>
/// The only thing the networking layer needs from URLSession. Tests replace it
/// with a stub that returns prepared responses.
public protocol HTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// The production implementation, backed by a URLSession.
public struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}
// </client>
