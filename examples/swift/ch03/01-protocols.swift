// Protocols, protocol extensions, and existential vs. opaque types.
protocol CareTask {
    var title: String { get }
    var intervalDays: Int { get }
    func isDue(daysSinceLastDone: Int) -> Bool
}

// A protocol extension provides a default implementation to every conforming type.
extension CareTask {
    func isDue(daysSinceLastDone: Int) -> Bool { daysSinceLastDone >= intervalDays }
    var summary: String { "\(title) every \(intervalDays) days" }
}

struct Watering: CareTask {
    let millilitres: Int
    var title: String { "Water \(millilitres) ml" }
    var intervalDays: Int { 7 }
}

struct Fertilizing: CareTask {
    let title = "Fertilize"
    let intervalDays = 30
    // Overrides the default: never fertilize during the winter rest.
    var winterRest = false
    func isDue(daysSinceLastDone: Int) -> Bool { !winterRest && daysSinceLastDone >= intervalDays }
}

// `any CareTask` is a box that can hold any conforming value (an existential).
let tasks: [any CareTask] = [Watering(millilitres: 300), Fertilizing(winterRest: true)]
for task in tasks {
    print(task.summary, "-> due after 40 days:", task.isDue(daysSinceLastDone: 40))
}

// `some CareTask` hides a single concrete type chosen by the function (an opaque type).
func defaultTask() -> some CareTask { Watering(millilitres: 200) }
print(defaultTask().summary)

// Generic code with a protocol constraint is resolved at compile time.
func describeAll<T: CareTask>(_ items: [T]) -> [String] { items.map(\.summary) }
print(describeAll([Watering(millilitres: 100), Watering(millilitres: 150)]))
