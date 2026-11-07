import SwiftUI

// <component>
/// A reusable labelled field with a validation message, used by several forms.
struct ValidatedField: View {
    let title: String
    @Binding var text: String
    var prompt: String = ""
    var validate: (String) -> String? = { _ in nil }  // returns an error message or nil
    @State private var hasEdited = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(title, text: $text, prompt: Text(prompt))
                .onChange(of: text) { hasEdited = true }
            if hasEdited, let message = validate(text) {
                Label(message, systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: validate(text))
    }
}

/// A modifier that gives text fields the same look outside of a Form.
struct RoundedFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.background.secondary, in: .rect(cornerRadius: 10))
            .overlay { RoundedRectangle(cornerRadius: 10).stroke(.quaternary) }
    }
}

extension View {
    func roundedField() -> some View { modifier(RoundedFieldStyle()) }
}
// </component>

// <usage>
struct FormComponentsView: View {
    @State private var postcode = ""
    @State private var nickname = ""

    var body: some View {
        VStack(spacing: 20) {
            ValidatedField(title: "Postcode", text: $postcode, prompt: "29200") { text in
                text.count == 5 && text.allSatisfy(\.isNumber) ? nil : "Five digits, please."
            }
            .roundedField()
            ValidatedField(title: "Nickname", text: $nickname, prompt: "Green fingers") {
                text in
                text.count < 3 ? "At least three characters." : nil
            }
            .roundedField()
        }
        .padding()
    }
}
// </usage>

#Preview { FormComponentsView() }
