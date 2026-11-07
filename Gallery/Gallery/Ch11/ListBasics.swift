import SwiftUI

// <static>
struct StaticListView: View {
    var body: some View {
        List {
            Section("Watering") {
                Label("Ferns: every 3 days", systemImage: "drop")
                Label("Cacti: every 3 weeks", systemImage: "drop")
            }
            Section {
                Text("Rotate pots a quarter turn each week.")
            } header: {
                Text("Light")
            } footer: {
                Text("Plants lean towards the window otherwise.")
            }
        }
        .listStyle(.insetGrouped)
    }
}
// </static>

// <dynamic>
/// A value with a stable identity: List and ForEach use `id` to follow each row.
struct Chore: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var isDone = false
}

struct DynamicListView: View {
    @State private var chores = [
        Chore(title: "Water the ferns"),
        Chore(title: "Repot the basil"),
        Chore(title: "Wipe the monstera leaves"),
        Chore(title: "Feed the citrus"),
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach($chores) { $chore in  // a binding per row
                    Toggle(chore.title, isOn: $chore.isDone)
                }
                .onDelete { offsets in chores.remove(atOffsets: offsets) }  // swipe
                .onMove { from, to in chores.move(fromOffsets: from, toOffset: to) }
            }
            .navigationTitle("Chores")
            .toolbar {
                EditButton()  // shows reorder handles
                Button("Add", systemImage: "plus") {
                    chores.append(Chore(title: "New chore \(chores.count + 1)"))
                }
            }
        }
    }
}
// </dynamic>

#Preview("Static") { StaticListView() }
#Preview("Dynamic") { DynamicListView() }
