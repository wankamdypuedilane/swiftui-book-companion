import SwiftUI

// <workshop>
/// A small interactive form: the button is enabled only when the input is valid.
struct WorkshopSignUpView: View {
    @State private var name = ""
    @State private var seats = 1
    @State private var bringsCuttings = false
    @State private var confirmation: String?

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var isValid: Bool { trimmedName.count >= 2 }

    var body: some View {
        Form {
            Section("Repotting workshop, Saturday 10:00") {
                TextField("Your name", text: $name)
                    .textContentType(.name)
                Stepper("Seats: \(seats)", value: $seats, in: 1...4)
                Toggle("I will bring cuttings to swap", isOn: $bringsCuttings)
            }
            Section {
                Button("Reserve") {
                    confirmation = "\(trimmedName), \(seats) seat(s) reserved."
                }
                .disabled(!isValid)
            } footer: {
                if !isValid { Text("Enter at least two characters.") }
            }
            if let confirmation {
                Section { Label(confirmation, systemImage: "checkmark.circle.fill") }
            }
        }
    }
}
// </workshop>

#Preview { WorkshopSignUpView() }
