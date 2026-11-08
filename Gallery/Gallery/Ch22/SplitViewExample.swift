import SwiftUI

// <split>
/// A sidebar, a list and a detail on iPad and Mac; a navigation stack on iPhone.
struct SplitViewExample: View {
    let rooms = ["Bathroom", "Bedroom", "Kitchen", "Living room"]
    let plantsByRoom = [
        "Bathroom": ["Fern"], "Bedroom": ["Snake plant"],
        "Kitchen": ["Basil", "Mint"], "Living room": ["Monstera", "Pothos"],
    ]
    @State private var room: String?
    @State private var plant: String?

    var body: some View {
        NavigationSplitView {
            List(rooms, id: \.self, selection: $room) { Text($0) }
                .navigationTitle("Rooms")
        } content: {
            if let room {
                List(plantsByRoom[room] ?? [], id: \.self, selection: $plant) { Text($0) }
                    .navigationTitle(room)
            } else {
                ContentUnavailableView("Choose a room", systemImage: "house")
            }
        } detail: {
            if let plant {
                Text(plant).font(.largeTitle)
            } else {
                ContentUnavailableView("Choose a plant", systemImage: "leaf")
            }
        }
    }
}
// </split>

#Preview { SplitViewExample() }
