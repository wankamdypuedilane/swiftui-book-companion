// Appendix A: a compact reference of Swift syntax. Every snippet runs.
import Foundation

// <values>
let fixed = 42  // constant, type inferred: Int
var counter: Double = 0.5  // variable with an explicit type
counter += 1
let name = "Kerbrume"
let greeting = "Hello, \(name)! \(fixed * 2)"  // string interpolation
let multiline = """
    Two lines,
    one string.
    """
let maybe: Int? = Int("17")  // optional: a value or nil
let sure = maybe ?? 0  // default value
print(greeting, counter, multiline.count, sure)
// </values>

// <collections>
var cities = ["Brest", "Quimper"]  // [String]
cities.append("Morlaix")
let populations = ["Brest": 139_000, "Quimper": 63_000]  // [String: Int]
let unique: Set = [3, 1, 3, 2]  // Set<Int>, no duplicates, no order
let pair = (latitude: 48.39, longitude: -4.48)  // tuple with labels
print(cities.count, populations["Brest"] ?? 0, unique.count, pair.latitude)
// </collections>

// <control>
for (index, city) in cities.enumerated() where index > 0 {
    print(index, city)
}
let size =
    switch populations["Quimper"] ?? 0 {
    case ..<10_000: "village"
    case 10_000..<100_000: "town"
    default: "city"
    }
if let brest = populations["Brest"], brest > 100_000 { print("Brest is large") }
guard let first = cities.first else { fatalError("no cities") }
print(size, first)
// </control>

// <functions>
func distance(from a: Double, to b: Double = 0) -> Double { abs(b - a) }
func swapValues<T>(_ x: inout T, _ y: inout T) { (x, y) = (y, x) }
let squares = (1...4).map { $0 * $0 }  // closure with shorthand argument
let evens = squares.filter { $0.isMultiple(of: 2) }
let total = squares.reduce(0, +)
var left = 1
var right = 2
swapValues(&left, &right)
print(distance(from: 3), squares, evens, total, left, right)
// </functions>

// <types>
struct Point: Equatable, CustomStringConvertible {  // value type: copied
    var x = 0.0, y = 0.0
    var description: String { "(\(x), \(y))" }  // computed property
    mutating func move(by delta: Double) { x += delta; y += delta }
}
final class Counter {  // reference type: shared
    private(set) var value = 0
    func increment() { value += 1 }
}
enum Light: String, CaseIterable {  // enumeration with raw values
    case low, medium, bright
}
enum Outcome {  // associated values
    case success(Int), failure(message: String)
}
var point = Point()
point.move(by: 2)
let shared = Counter()
let alias = shared
alias.increment()
let outcome = Outcome.failure(message: "offline")
if case .failure(let message) = outcome { print(message) }
print(point, shared.value, Light.allCases.map(\.rawValue))
// </types>

// <protocols>
protocol Describable {
    var summary: String { get }
}
extension Describable {  // default implementation
    func shout() -> String { summary.uppercased() }
}
extension Point: Describable {
    var summary: String { "point at \(description)" }
}
func describeAll(_ items: [any Describable]) -> [String] { items.map(\.summary) }
func loudest(_ item: some Describable) -> String { item.shout() }
print(describeAll([point]), loudest(point))
// </protocols>

// <errors>
enum ParseError: Error { case empty, notANumber(String) }
func parse(_ text: String) throws(ParseError) -> Int {  // typed throws (Swift 6)
    guard !text.isEmpty else { throw .empty }
    guard let value = Int(text) else { throw .notANumber(text) }
    return value
}
do {
    print(try parse("12"))
    print(try parse("twelve"))
} catch .notANumber(let text) {
    print("not a number:", text)
} catch {
    print("other error:", error)
}
let optionalValue = try? parse("")  // nil instead of an error
print(optionalValue as Any)
// </errors>

// <concurrency>
actor Tally {  // an actor protects its state from data races
    private var count = 0
    func add(_ n: Int) -> Int {
        count += n
        return count
    }
}
func fetchNumber(_ n: Int) async -> Int {
    try? await Task.sleep(for: .milliseconds(10 * n))
    return n
}
func runConcurrency() async {
    async let a = fetchNumber(2)  // runs concurrently
    async let b = fetchNumber(1)
    let sum = await a + b
    let tally = Tally()
    let results = await withTaskGroup(of: Int.self) { group in
        for n in 1...3 { group.addTask { await tally.add(n) } }
        var last = 0
        for await value in group { last = max(last, value) }
        return last
    }
    print(sum, results)
}
await runConcurrency()
// </concurrency>
