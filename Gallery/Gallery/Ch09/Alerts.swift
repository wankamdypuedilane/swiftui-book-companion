import SwiftUI

// <alerts>
struct AlertsView: View {
    @State private var specimens = Specimen.samples
    @State private var pendingDeletion: Specimen?
    @State private var showsSyncError = false

    var body: some View {
        List {
            ForEach(specimens) { specimen in
                HStack {
                    Text(specimen.name)
                    Spacer()
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        pendingDeletion = specimen
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                }
            }
            Button("Simulate a sync error") { showsSyncError = true }
        }
        // An alert: a short message that needs acknowledgement or a simple choice.
        .alert("Sync failed", isPresented: $showsSyncError) {
            Button("Retry") {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Check your connection and try again.")
        }
        // A confirmation dialog: a choice related to an action the user started.
        .confirmationDialog("Delete this plant?",
                            isPresented: Binding(get: { pendingDeletion != nil },
                                                 set: { if !$0 { pendingDeletion = nil } }),
                            titleVisibility: .visible,
                            presenting: pendingDeletion) { specimen in
            Button("Delete \(specimen.name)", role: .destructive) {
                specimens.removeAll { $0.id == specimen.id }
            }
        } message: { specimen in
            Text("Its care history will be lost.")
        }
    }
}
// </alerts>

#Preview { AlertsView() }
