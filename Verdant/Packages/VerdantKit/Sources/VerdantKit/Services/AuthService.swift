import Foundation

// <auth>
/// Signing in and refreshing tokens. These endpoints do not require a token.
public struct AuthService: Sendable {
    private let client: APIClient

    public init(client: APIClient) { self.client = client }

    private struct Credentials: Encodable { let email: String; let password: String }
    private struct RefreshRequest: Encodable { let refreshToken: String }
    private struct TokenResponse: Decodable, Sendable {
        let accessToken: String
        let refreshToken: String
        let expiresIn: Int  // seconds
        let email: String
    }

    public func signIn(
        email: String, password: String,
        now: Date = .now
    ) async throws(APIError) -> AuthSession {
        let body = try Self.encode(Credentials(email: email, password: password))
        let response = try await client.send(
            Endpoint<TokenResponse>(.post, "auth/token", body: body))
        return Self.session(from: response, now: now)
    }

    public func refresh(
        refreshToken: String, now: Date = .now
    ) async throws(APIError) -> AuthSession {
        let body = try Self.encode(RefreshRequest(refreshToken: refreshToken))
        let response = try await client.send(
            Endpoint<TokenResponse>(.post, "auth/refresh", body: body))
        return Self.session(from: response, now: now)
    }

    private static func session(from response: TokenResponse, now: Date) -> AuthSession {
        AuthSession(
            email: response.email, accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: now.addingTimeInterval(TimeInterval(response.expiresIn)))
    }

    private static func encode(_ value: some Encodable) throws(APIError) -> Data {
        do { return try APIClient.makeEncoder().encode(value) } catch {
            throw .invalidRequest("Could not encode the request body")
        }
    }
}
// </auth>
