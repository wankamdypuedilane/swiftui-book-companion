import SwiftUI

// <input>
/// Text fields, a secure field, focus management, keyboard types and validation.
struct TextInputView: View {
    enum Field: Hashable { case name, email, password, bio }

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var bio = ""
    @FocusState private var focus: Field?

    private var emailIsValid: Bool {
        email.wholeMatch(of: /[^@\s]+@[^@\s]+\.[A-Za-z]{2,}/) != nil
    }

    var body: some View {
        Form {
            TextField("Display name", text: $name)
                .textContentType(.name)  // lets iOS suggest the user's name
                .submitLabel(.next)
                .focused($focus, equals: .name)
                .onSubmit { focus = .email }

            VStack(alignment: .leading) {
                TextField("E-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focus, equals: .email)
                    .onSubmit { focus = .password }
                if !email.isEmpty && !emailIsValid {
                    Text("Enter an address such as name@example.com.")
                        .font(.caption).foregroundStyle(.red)
                }
            }

            SecureField("Password (8 characters minimum)", text: $password)
                .textContentType(.newPassword)  // offers a strong generated password
                .submitLabel(.next)
                .focused($focus, equals: .password)
                .onSubmit { focus = .bio }

            TextField("About your plants", text: $bio, axis: .vertical)
                .lineLimit(2...5)
                .focused($focus, equals: .bio)

            Button("Create account") { focus = nil }
                .disabled(name.isEmpty || !emailIsValid || password.count < 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus = nil }
            }
        }
        .onAppear { focus = .name }
    }
}
// </input>

#Preview { TextInputView() }
