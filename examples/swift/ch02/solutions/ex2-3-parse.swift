import Foundation
// Exercise 2.3: parse "name:days" lines, collecting errors instead of crashing.
enum LineError: Error, CustomStringConvertible {
    case missingSeparator(line: Int)
    case emptyName(line: Int)
    case badInterval(line: Int, text: String)
    var description: String {
        switch self {
        case .missingSeparator(let n): "line \(n): expected name:days"
        case .emptyName(let n): "line \(n): the name is empty"
        case .badInterval(let n, let text): "line \(n): \"\(text)\" is not a number of days"
        }
    }
}

func parseLine(_ text: String, number: Int) throws(LineError) -> (String, Int) {
    let parts = text.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false).map { $0.trimmingCharacters(in: .whitespaces) }
    guard parts.count == 2 else { throw .missingSeparator(line: number) }
    guard !parts[0].isEmpty else { throw .emptyName(line: number) }
    guard let days = Int(parts[1]), days > 0 else { throw .badInterval(line: number, text: parts[1]) }
    return (parts[0], days)
}

let input = """
Fern: 3
Cactus:21
Pothos 7
: 5
Calathea: often
Snake plant: 14
"""

var schedule: [String: Int] = [:]
var errors: [LineError] = []
for (index, line) in input.split(separator: "\n").enumerated() {
    do {
        let (name, days) = try parseLine(String(line), number: index + 1)
        schedule[name] = days
    } catch {
        errors.append(error)
    }
}
print("Parsed:", schedule.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))
errors.forEach { print("Skipped", $0) }
