import StreetPatchKit
import SwiftUI

// <signin>
/// Signing in with the town account. The fields declare their content type so that
/// AutoFill and password managers can fill them.
struct SignInView: View {
    @Environment(SessionModel.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("E-mail", text: $email)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("signIn.email")
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .accessibilityIdentifier("signIn.password")
                } footer: {
                    #if DEBUG
                    Text("Local demo: resident@streetpatch.example / local-only-demo-password")
                    #endif
                }
                if let message = session.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sign in") {
                        Task {
                            await session.signIn(email: email, password: password)
                            if session.isSignedIn { dismiss() }
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || session.isWorking)
                    .accessibilityIdentifier("signIn.submit")
                }
            }
        }
    }
}
// </signin>
