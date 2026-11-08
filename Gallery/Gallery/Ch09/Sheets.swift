import SwiftUI

// <sheets>
struct SheetsView: View {
    @State private var showsTips = false
    @State private var editing: Specimen?  // non-nil while the sheet is shown
    @State private var showsWelcome = false

    var body: some View {
        List {
            Button("Care tips (half-height sheet)") { showsTips = true }
            ForEach(Specimen.samples) { specimen in
                Button("Rename \(specimen.name)") { editing = specimen }
            }
            Button("Welcome (full screen)") { showsWelcome = true }
        }
        .sheet(isPresented: $showsTips) {
            Text("Water less in winter.")
                .font(.title2)
                .presentationDetents([.medium, .large])  // half height, can be enlarged
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $editing) { specimen in  // one sheet per item
            RenameSheet(specimen: specimen)
        }
        .fullScreenCover(isPresented: $showsWelcome) {
            WelcomeCover()
        }
    }
}

struct RenameSheet: View {
    @Environment(\.dismiss) private var dismiss  // closes the presentation
    @State private var name: String

    init(specimen: Specimen) { _name = State(initialValue: specimen.name) }  // a draft

    var body: some View {
        NavigationStack {
            Form { TextField("Name", text: $name) }
                .navigationTitle("Rename")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { dismiss() }.disabled(name.isEmpty)
                    }
                }
        }
    }
}

struct WelcomeCover: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            Text("Welcome!").font(.largeTitle.bold())
            Button("Start") { dismiss() }.buttonStyle(.borderedProminent)
        }
    }
}
// </sheets>

#Preview { SheetsView() }
