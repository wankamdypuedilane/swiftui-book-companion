import SwiftUI

// <editing>
/// The list owns the array; the detail screen edits one element through a binding.
struct EditableListView: View {
    @State private var specimens = Specimen.samples

    var body: some View {
        NavigationStack {
            List($specimens) { $specimen in                       // a binding per element
                NavigationLink {
                    SpecimenEditor(specimen: $specimen)
                } label: {
                    VStack(alignment: .leading) {
                        Text(specimen.name)
                        if !specimen.notes.isEmpty {
                            Text(specimen.notes).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit in place")
        }
    }
}

struct SpecimenEditor: View {
    @Binding var specimen: Specimen

    var body: some View {
        Form {
            TextField("Name", text: $specimen.name)              // binding to a property
            TextField("Room", text: $specimen.room)
            TextField("Notes", text: $specimen.notes, axis: .vertical)
                .lineLimit(3...6)
        }
        .navigationTitle(specimen.name)
    }
}
// </editing>

#Preview { EditableListView() }
