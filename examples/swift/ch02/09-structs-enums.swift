// Structures and enumerations.
enum Light: String, CaseIterable {
    case low, medium, bright
    var symbol: String { switch self { case .low: "◐"; case .medium: "◑"; case .bright: "●" } }
}

struct Plant {
    let name: String
    var light: Light
    var wateringIntervalDays: Int
    var daysSinceWatering = 0

    var needsWater: Bool { daysSinceWatering >= wateringIntervalDays }

    mutating func water() { daysSinceWatering = 0 }
}

var fern = Plant(name: "Boston fern", light: .medium, wateringIntervalDays: 3)
fern.daysSinceWatering = 4
print(fern.name, fern.light, fern.light.rawValue, fern.light.symbol, fern.needsWater)
fern.water()
print(fern.needsWater)

// Structures are value types: assignment copies.
var copy = fern
copy.wateringIntervalDays = 10
print(fern.wateringIntervalDays, copy.wateringIntervalDays)

print(Light.allCases.map(\.rawValue))
print(Light(rawValue: "bright") == .bright, Light(rawValue: "dim") == nil)

// Associated values carry data with each case.
enum CareEvent {
    case watered(millilitres: Int)
    case fertilized(product: String)
    case repotted
}
let history: [CareEvent] = [.watered(millilitres: 250), .fertilized(product: "GrowMix"), .repotted]
for event in history {
    switch event {
    case .watered(let ml): print("Watered with \(ml) ml")
    case .fertilized(let product): print("Fertilized with \(product)")
    case .repotted: print("Repotted")
    }
}
