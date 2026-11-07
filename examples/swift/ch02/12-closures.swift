// Closures and higher-order functions.
struct Plant { let name: String; let intervalDays: Int; let daysSinceWatering: Int }
let plants = [
    Plant(name: "Fern", intervalDays: 3, daysSinceWatering: 4),
    Plant(name: "Cactus", intervalDays: 21, daysSinceWatering: 5),
    Plant(name: "Pothos", intervalDays: 7, daysSinceWatering: 7),
    Plant(name: "Calathea", intervalDays: 5, daysSinceWatering: 1),
]

let thirsty = plants.filter { $0.daysSinceWatering >= $0.intervalDays }
print(thirsty.map(\.name))

let byUrgency = plants.sorted { ($0.intervalDays - $0.daysSinceWatering) < ($1.intervalDays - $1.daysSinceWatering) }
print(byUrgency.map(\.name))

let totalDays = plants.reduce(0) { partial, plant in partial + plant.intervalDays }
print("Sum of intervals:", totalDays)

let inputs = ["3", "x", "14"]
print(inputs.compactMap { Int($0) })

// A closure can capture and keep state.
func makeCounter() -> () -> Int {
    var count = 0
    return { count += 1; return count }
}
let next = makeCounter()
print(next(), next(), next())

// Functions are values: pass one where a closure is expected.
func isLong(_ name: String) -> Bool { name.count > 5 }
print(plants.map(\.name).filter(isLong))
