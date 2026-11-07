import SwiftUI

// <lifting>
/// Two sibling views share the same value: the state lives in their common parent.
struct RoomFilterScreen: View {
    @State private var selectedRoom = "All"
    let rooms = ["All", "Kitchen", "Bedroom", "Office"]
    let plants = [("Basil", "Kitchen"), ("Snake plant", "Bedroom"),
                  ("Pothos", "Office"), ("Mint", "Kitchen")]

    var body: some View {
        VStack(spacing: 0) {
            RoomPicker(rooms: rooms, selection: $selectedRoom)        // writes
            PlantNameList(names: plants
                .filter { selectedRoom == "All" || $0.1 == selectedRoom }
                .map(\.0))                                            // reads
        }
    }
}

struct RoomPicker: View {
    let rooms: [String]
    @Binding var selection: String

    var body: some View {
        Picker("Room", selection: $selection) {
            ForEach(rooms, id: \.self) { Text($0) }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

struct PlantNameList: View {
    let names: [String]          // plain data: this view only displays

    var body: some View {
        List(names, id: \.self) { Text($0) }
    }
}
// </lifting>

#Preview { RoomFilterScreen() }
