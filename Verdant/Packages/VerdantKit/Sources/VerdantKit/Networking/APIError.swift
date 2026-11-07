import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// <error>
/// Every way a request can fail, in terms the app can act on.
public enum APIError: Error, Equatable, Sendable {
    case invalidRequest(String)  // a bug: the request could not be built
    case offline  // no network connection
    case timedOut
    case transport(String)  // other network failure
    case unauthorized  // 401: sign in again
    case http(status: Int, message: String?)  // any other non-2xx status
    case decoding(String)  // the response does not match the model
    case cancelled

    /// Failures worth trying again automatically.
    public var isRetryable: Bool {
        switch self {
        case .offline, .timedOut, .transport: true
        case .http(let status, _): status == 429 || (500...599).contains(status)
        default: false
        }
    }

    /// A sentence suitable for the user interface.
    public var userMessage: String {
        switch self {
        case .offline: "You are offline. Check your connection and try again."
        case .timedOut: "The server took too long to answer."
        case .unauthorized: "Your session has expired. Please sign in again."
        case .http(let status, let message) where (400...499).contains(status):
            message ?? "The request was refused (\(status))."
        case .http: "The server had a problem. Try again in a moment."
        case .decoding: "The server sent data this version of Verdant cannot read."
        case .invalidRequest, .transport: "Something went wrong. Try again."
        case .cancelled: "The request was cancelled."
        }
    }

    /// Maps a URLSession error to an APIError.
    static func from(_ error: any Error) -> APIError {
        if error is CancellationError { return .cancelled }
        guard let urlError = error as? URLError else {
            return .transport(String(describing: error))
        }
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed: return .offline
        case .timedOut: return .timedOut
        case .cancelled: return .cancelled
        default: return .transport(urlError.localizedDescription)
        }
    }
}
// </error>
