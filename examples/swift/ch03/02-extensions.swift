// Extensions add functionality to existing types, including ones you did not write.
import Foundation

extension Int {
    var days: TimeInterval { TimeInterval(self) * 86_400 }
}

extension String {
    /// "boston fern" -> "Boston Fern"
    var titleCased: String {
        split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
    }
}

extension Array where Element == Int {
    var average: Double { isEmpty ? 0 : Double(reduce(0, +)) / Double(count) }
}

struct Plant { let name: String; let heightCm: Int }

// Conformances are often added in an extension, which keeps them grouped.
extension Plant: CustomStringConvertible {
    var description: String { "\(name.titleCased) (\(heightCm) cm)" }
}

let start = Date(timeIntervalSince1970: 0)
let next = start.addingTimeInterval(3.days)
print(next.timeIntervalSince(start) / 3_600, "hours later")
print("peace lily".titleCased)
print([12, 30, 45].average)
print(Plant(name: "rubber plant", heightCm: 80))
