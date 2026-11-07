import Foundation
import Observation

// <sessionmodel>
/// Signing in. Browsing works without an account; reporting and supporting need one.
@MainActor
@Observable
public final class SessionModel {
    public private(set) var email: String?
    public private(set) var errorMessage: String?
    public private(set) var isWorking = false

    @ObservationIgnored private let auth: AuthService
    @ObservationIgnored private let authenticator: Authenticator

    public init(auth: AuthService, authenticator: Authenticator) {
        self.auth = auth
        self.authenticator = authenticator
    }

    public var isSignedIn: Bool { email != nil }

    public func restore() async {
        email = await authenticator.currentSession?.email
    }

    public func signIn(email: String, password: String) async {
        isWorking = true
        defer { isWorking = false }
        do {
            let session = try await auth.signIn(
                email: email.trimmingCharacters(in: .whitespaces), password: password)
            await authenticator.signIn(with: session)
            self.email = session.email
            errorMessage = nil
        } catch {
            errorMessage = error.userMessage
        }
    }

    public func signOut() async {
        await authenticator.signOut()
        email = nil
    }
}
// </sessionmodel>
