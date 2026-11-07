// Classes: reference semantics, inheritance, initializers and deinitializers.
class Sensor {
    let id: String
    private(set) var readings: [Double] = []

    init(id: String) { self.id = id }
    deinit { print("Sensor \(id) released") }

    func record(_ value: Double) { readings.append(value) }
    func describe() -> String { "Sensor \(id): \(readings.count) readings" }
}

final class MoistureSensor: Sensor {
    let threshold: Double
    init(id: String, threshold: Double) {
        self.threshold = threshold        // phase 1: initialize own properties
        super.init(id: id)                // then the superclass
    }
    var isDry: Bool { (readings.last ?? 100) < threshold }
    override func describe() -> String { super.describe() + (isDry ? " (dry)" : " (ok)") }
}

let kitchen = MoistureSensor(id: "K1", threshold: 30)
let alias = kitchen                       // same object, not a copy
alias.record(42)
alias.record(18)
print(kitchen.describe())
print("same object:", kitchen === alias)

// Polymorphism: an array of the superclass type, dynamic dispatch on describe().
let sensors: [Sensor] = [kitchen, Sensor(id: "T7")]
sensors.forEach { print($0.describe()) }

do {
    let temporary = Sensor(id: "TMP")
    temporary.record(1)
}                                         // last reference gone: deinit runs here
print("end of program")
