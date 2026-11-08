import SwiftUI
import VerdantKit

// <accountsection>
/// Signing in and backing up the garden.
struct AccountSection: View {
    @Environment(AccountModel.self) private var account

    var body: some View {
        @Bindable var account = account
        Section {
            switch account.status {
            case .signedOut, .signingIn:
                TextField("E-mail", text: $account.email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password", text: $account.password)
                    .textContentType(.password)
                Button {
                    Task { await account.signIn() }
                } label: {
                    if account.status == .signingIn { ProgressView() } else { Text("Sign in") }
                }
                .disabled(!account.canSignIn)
            case .signedIn(let email):
                LabeledContent("Signed in as", value: email)
                Button("Back up my garden", systemImage: "icloud.and.arrow.up") {
                    Task { await account.backUp() }
                }
                Button("Restore from backup", systemImage: "icloud.and.arrow.down") {
                    Task { await account.restoreBackup() }
                }
                Button("Sign out", role: .destructive) { Task { await account.signOut() } }
            }
            if account.isWorking { ProgressView() }
        } header: {
            Text("Account")
        } footer: {
            if let message = account.message { Text(message) }
        }
    }
}
// </accountsection>
