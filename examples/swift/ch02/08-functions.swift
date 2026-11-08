// Functions: labels, defaults, variadic and inout parameters, overloading, tuples.
func greet(_ name: String, from place: String = "Verdant") -> String {
    "Hello \(name), greetings from \(place)!"
}
print(greet("Amina"))
print(greet("Yann", from: "the greenhouse"))

func average(of values: Double...) -> Double {
    values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
}
print(average(of: 4, 8, 15))

func water(_ level: inout Int, by amount: Int) { level = min(100, level + amount) }
var moisture = 70
water(&moisture, by: 45)
print("moisture:", moisture)

// Overloading: same name, different parameter types or labels.
func describe(_ value: Int) -> String { "integer \(value)" }
func describe(_ value: Double) -> String { "decimal \(value)" }
func describe(days value: Int) -> String { "\(value) days" }
print(describe(3), "|", describe(3.5), "|", describe(days: 3))

// Returning several values with a tuple.
func minMax(_ values: [Int]) -> (min: Int, max: Int)? {
    guard let first = values.first else { return nil }
    return values.dropFirst().reduce((first, first)) { (min($0.0, $1), max($0.1, $1)) }
}
if let range = minMax([21, 7, 14, 3]) { print("min \(range.min), max \(range.max)") }
