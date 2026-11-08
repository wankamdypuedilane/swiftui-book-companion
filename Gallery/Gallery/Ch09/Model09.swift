import Foundation

// <model>
/// A small, self-contained model for the navigation examples.
struct Specimen: Identifiable, Hashable {
    let id: Int
    var name: String
    var room: String
    var notes: String = ""

    static let samples = [
        Specimen(id: 1, name: "Monstera", room: "Living room"),
        Specimen(id: 2, name: "Snake plant", room: "Bedroom"),
        Specimen(id: 3, name: "Basil", room: "Kitchen"),
    ]
}
// </model>
