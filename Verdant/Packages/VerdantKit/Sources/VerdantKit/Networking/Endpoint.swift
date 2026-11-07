import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// <endpoint>
/// A description of one API call and of the type of its response.
public struct Endpoint<Response: Decodable & Sendable>: Sendable {
    public enum Method: String, Sendable {
        case get = "GET", post = "POST", put = "PUT",
            patch = "PATCH", delete = "DELETE"
    }

    public var method: Method
    public var path: String
    public var queryItems: [URLQueryItem]
    public var body: Data?
    public var requiresAuthentication: Bool

    public init(
        _ method: Method = .get, _ path: String, query: [URLQueryItem] = [],
        body: Data? = nil, requiresAuthentication: Bool = false
    ) {
        self.method = method
        self.path = path
        self.queryItems = query
        self.body = body
        self.requiresAuthentication = requiresAuthentication
    }

    /// Builds the URLRequest relative to a base URL such as https://api.verdant.example/v1/.
    func urlRequest(baseURL: URL, timeout: TimeInterval) throws(APIError) -> URLRequest {
        let relative = path.hasPrefix("/") ? String(path.dropFirst()) : path
        guard
            var components = URLComponents(
                url: baseURL.appendingPathComponent(relative),
                resolvingAgainstBaseURL: false)
        else {
            throw .invalidRequest(path)
        }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        guard let url = components.url else { throw .invalidRequest(path) }
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}

/// The response type of calls that return no content (204).
public struct NoContent: Decodable, Sendable {
    public init() {}
}
// </endpoint>
