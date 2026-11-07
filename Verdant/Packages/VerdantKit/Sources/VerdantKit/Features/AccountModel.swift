import Foundation
import Observation

// <account>
/// Signing in and backing up the garden (Settings tab).
@MainActor
@Observable
public final class AccountModel {
    public enum Status: Equatable {
        case signedOut, signingIn, signedIn(email: String)
    }

    public private(set) var status = Status.signedOut
    public private(set) var message: String?
    public private(set) var isWorking = false
    public var email = ""
    public var password = ""

    @ObservationIgnored private let auth: AuthService
    @ObservationIgnored private let authenticator: Authenticator
    @ObservationIgnored private let backup: any BackupService
    @ObservationIgnored private let garden: Garden

    public init(auth: AuthService, authenticator: Authenticator, backup: any BackupService,
                garden: Garden) {
        self.auth = auth
        self.authenticator = authenticator
        self.backup = backup
        self.garden = garden
    }

    public var canSignIn: Bool {
        email.contains("@") && password.count >= 8 && status == .signedOut
    }

    /// Restores a session saved during a previous launch.
    public func restore() async {
        if let session = await authenticator.currentSession {
            status = .signedIn(email: session.email)
        }
    }

    public func signIn() async {
        status = .signingIn
        message = nil
        do {
            let session = try await auth.signIn(email: email, password: password)
            await authenticator.signIn(with: session)
            password = ""                                   // never keep the password
            status = .signedIn(email: session.email)
        } catch {
            status = .signedOut
            message = error == .unauthorized ? "Wrong e-mail or password." : error.userMessage
        }
    }

    public func signOut() async {
        await authenticator.signOut()
        status = .signedOut
        message = nil
    }

    public func backUp() async {
        await run { () async throws(APIError) -> String in    // typed throws must be spelled out
            let receipt = try await self.backup.upload(self.garden.plants)
            return "\(receipt.plantCount) plants backed up."
        }
    }

    public func restoreBackup() async {
        await run { () async throws(APIError) -> String in
            let plants = try await self.backup.download()
            await self.garden.replaceAll(with: plants)
            return "\(plants.count) plants restored."
        }
    }

    private func run(_ operation: () async throws(APIError) -> String) async {
        isWorking = true
        defer { isWorking = false }
        do {
            message = try await operation()
        } catch {
            if error == .unauthorized { status = .signedOut }
            message = error.userMessage
        }
    }
}
// </account>
