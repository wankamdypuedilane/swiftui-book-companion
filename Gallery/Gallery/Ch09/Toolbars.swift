import SwiftUI

// <toolbar>
struct ToolbarsView: View {
    @State private var isEditing = false
    @State private var sortAscending = true

    var body: some View {
        NavigationStack {
            List(sortedNames, id: \.self) { Text($0) }
                .navigationTitle("Toolbar")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(isEditing ? "Done" : "Edit") { isEditing.toggle() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            Picker("Order", selection: $sortAscending) {
                                Text("A to Z").tag(true)
                                Text("Z to A").tag(false)
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Water all", systemImage: "drop") {}
                        Spacer()
                        Text("\(sortedNames.count) plants").font(.footnote)
                        Spacer()
                        Button("Add", systemImage: "plus") {}
                    }
                }
        }
    }

    private var sortedNames: [String] {
        let names = Specimen.samples.map(\.name).sorted()
        return sortAscending ? names : names.reversed()
    }
}
// </toolbar>

#Preview { ToolbarsView() }
