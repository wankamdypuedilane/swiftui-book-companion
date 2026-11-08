import SwiftUI

// <selection>
/// A view model that manages a multiple selection and bulk actions.
@Observable
final class TrayModel {
    struct Seedling: Identifiable, Equatable {
        let id: Int
        var name: String
        var isPricked = false
    }

    var seedlings = (1...12).map { Seedling(id: $0, name: "Seedling \($0)") }
    var selection = Set<Seedling.ID>()

    var selectedCount: Int { selection.count }
    var canPrick: Bool { seedlings.contains { selection.contains($0.id) && !$0.isPricked } }

    func prickOutSelection() {
        for index in seedlings.indices where selection.contains(seedlings[index].id) {
            seedlings[index].isPricked = true
        }
        selection.removeAll()
    }

    func deleteSelection() {
        seedlings.removeAll { selection.contains($0.id) }
        selection.removeAll()
    }
}

struct SelectionView: View {
    @State private var model = TrayModel()

    var body: some View {
        NavigationStack {
            List(model.seedlings, selection: $model.selection) { seedling in
                Label(seedling.name, systemImage: seedling.isPricked ? "leaf.fill" : "leaf")
            }
            .environment(\.editMode, .constant(.active))  // always selectable
            .navigationTitle("\(model.selectedCount) selected")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Prick out") { model.prickOutSelection() }
                        .disabled(!model.canPrick)
                    Spacer()
                    Button("Delete", role: .destructive) { model.deleteSelection() }
                        .disabled(model.selection.isEmpty)
                }
            }
        }
    }
}
// </selection>

#Preview { SelectionView() }
