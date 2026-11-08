import SwiftUI

// <search>
struct SearchFilterSortView: View {
    enum Order { case name, interval }
    struct Item: Identifiable {
        let id: Int
        let name: String
        let intervalDays: Int
        let edible: Bool
    }

    let items = [
        Item(id: 1, name: "Basil", intervalDays: 2, edible: true),
        Item(id: 2, name: "Snake plant", intervalDays: 21, edible: false),
        Item(id: 3, name: "Mint", intervalDays: 3, edible: true),
        Item(id: 4, name: "Boston fern", intervalDays: 3, edible: false),
        Item(id: 5, name: "Rosemary", intervalDays: 10, edible: true),
    ]

    @State private var searchText = ""
    @State private var order = Order.name
    @State private var edibleOnly = false

    /// Derived from the state on every update: never stored.
    private var results: [Item] {
        items
            .filter { !edibleOnly || $0.edible }
            .filter { searchText.isEmpty || $0.name.localizedStandardContains(searchText) }
            .sorted {
                order == .name ? $0.name < $1.name : $0.intervalDays < $1.intervalDays
            }
    }

    var body: some View {
        NavigationStack {
            List(results) { item in
                LabeledContent(item.name, value: "every \(item.intervalDays) d")
            }
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .searchable(text: $searchText, prompt: "Plant name")
            .navigationTitle("Herbs and friends")
            .toolbar {
                Menu("Options", systemImage: "line.3.horizontal.decrease.circle") {
                    Picker("Sort by", selection: $order) {
                        Text("Name").tag(Order.name)
                        Text("Watering interval").tag(Order.interval)
                    }
                    Toggle("Edible only", isOn: $edibleOnly)
                }
            }
        }
    }
}
// </search>

#Preview { SearchFilterSortView() }
