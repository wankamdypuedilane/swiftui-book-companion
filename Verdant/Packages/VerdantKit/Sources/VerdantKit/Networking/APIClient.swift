import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// <configuration>
public struct APIConfiguration: Sendable {
    public var baseURL: URL
    public var timeout: TimeInterval
    public var maxAttempts: Int
    public var retryDelay: Duration  // doubled after each failed attempt

    public init(
        baseURL: URL, timeout: TimeInterval = 15, maxAttempts: Int = 3,
        retryDelay: Duration = .milliseconds(500)
    ) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.maxAttempts = maxAttempts
        self.retryDelay = retryDelay
    }
}
// </configuration>

// <apiclient>
/// Sends endpoints, adds authentication, retries transient failures and decodes
/// JSON. It holds no mutable state, so it can be shared freely across tasks.
public final class APIClient: Sendable {
    public let configuration: APIConfiguration
    private let http: any HTTPClient
    private let authenticator: Authenticator?

    public init(
        configuration: APIConfiguration, http: any HTTPClient = URLSessionHTTPClient(),
        authenticator: Authenticator? = nil
    ) {
        self.configuration = configuration
        self.http = http
        self.authenticator = authenticator
    }

    public static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    public func send<Response>(
        _ endpoint: Endpoint<Response>
    ) async throws(APIError) -> Response {
        var attempt = 1
        var delay = configuration.retryDelay
        while true {
            do {
                return try await sendOnce(endpoint)
            } catch let error where error.isRetryable && attempt < configuration.maxAttempts {
                attempt += 1
                do { try await Task.sleep(for: delay) } catch { throw .cancelled }
                delay *= 2
            } catch .unauthorized where endpoint.requiresAuthentication && attempt == 1 {
                // The token may have been revoked: refresh once and retry.
                await authenticator?.invalidateAccessToken()
                attempt += 1
            }
        }
    }

    private func sendOnce<Response>(
        _ endpoint: Endpoint<Response>
    ) async throws(APIError) -> Response {
        var request = try endpoint.urlRequest(
            baseURL: configuration.baseURL,
            timeout: configuration.timeout)
        if endpoint.requiresAuthentication {
            guard let authenticator else { throw .unauthorized }
            let token = try await authenticator.validAccessToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data, response: URLResponse
        do {
            (data, response) = try await http.data(for: request)
        } catch {
            throw APIError.from(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw .transport("Not an HTTP response")
        }
        switch http.statusCode {
        case 200...299:
            if Response.self == NoContent.self, let empty = NoContent() as? Response {
                return empty
            }
            do {
                return try Self.makeDecoder().decode(Response.self, from: data)
            } catch {
                throw .decoding(String(describing: error))
            }
        case 401:
            throw .unauthorized
        default:
            let message = try? Self.makeDecoder().decode(ServerMessage.self, from: data).error
            throw .http(status: http.statusCode, message: message)
        }
    }

    /// The error body sent by the Verdant API: {"error": "..."}.
    private struct ServerMessage: Decodable { let error: String }
}
// </apiclient>
