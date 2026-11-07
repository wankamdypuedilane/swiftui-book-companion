import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// <endpoint>
/// One API call and the type of its response. Compared with Verdant's version, it
/// carries extra headers (Idempotency-Key) and bodies of any content type (JPEG).
public struct Endpoint<Response: Decodable & Sendable>: Sendable {
    public enum Method: String, Sendable {
        case get = "GET", post = "POST", put = "PUT",
            patch = "PATCH", delete = "DELETE"
    }

    public var method: Method
    public var path: String
    public var queryItems: [URLQueryItem]
    public var body: Data?
    public var contentType: String
    public var headers: [String: String]
    public var requiresAuthentication: Bool

    public init(
        _ method: Method = .get, _ path: String, query: [URLQueryItem] = [],
        body: Data? = nil, contentType: String = "application/json",
        headers: [String: String] = [:], requiresAuthentication: Bool = false
    ) {
        self.method = method
        self.path = path
        self.queryItems = query
        self.body = body
        self.contentType = contentType
        self.headers = headers
        self.requiresAuthentication = requiresAuthentication
    }

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
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        for (name, value) in headers { request.setValue(value, forHTTPHeaderField: name) }
        return request
    }
}

public struct NoContent: Decodable, Sendable {
    public init() {}
}
// </endpoint>
