// Collection transformations used by view models.
struct Plant: Equatable {
    let name: String
    let room: String
    let intervalDays: Int
    var isFavorite = false
}

let plants = [
    Plant(name: "Monty", room: "Living room", intervalDays: 7, isFavorite: true),
    Plant(name: "Goldie", room: "Office", intervalDays: 7),
    Plant(name: "Basil", room: "Kitchen", intervalDays: 2),
    Plant(name: "Thyme", room: "Kitchen", intervalDays: 3, isFavorite: true),
]

// <transform>
// Several figures in a single pass with reduce(into:).
struct Summary: Equatable { var count = 0, favourites = 0, waterPerWeek = 0.0 }
let summary = plants.reduce(into: Summary()) { result, plant in
    result.count += 1
    if plant.isFavorite { result.favourites += 1 }
    result.waterPerWeek += 7.0 / Double(plant.intervalDays)
}
print(summary.count, summary.favourites, summary.waterPerWeek)

// Grouping, then ordering the groups.
let byRoom = Dictionary(grouping: plants, by: \.room)
for room in byRoom.keys.sorted() {
    print(room, byRoom[room]!.map(\.name))
}

// Equatable lets SwiftUI and tests compare whole values.
var edited = plants[0]
edited.isFavorite.toggle()
print(edited == plants[0], plants.contains(edited))

// Selection: a Set of identifiers, then the selected values in display order.
let selected: Set<String> = ["Thyme", "Monty"]
print(plants.filter { selected.contains($0.name) }.map(\.name))
// </transform>
