// Error handling: throwing, catching, try? and typed throws.
enum IntervalError: Error, CustomStringConvertible {
    case notANumber(String)
    case outOfRange(Int)
    var description: String {
        switch self {
        case .notANumber(let text): "\"\(text)\" is not a number"
        case .outOfRange(let value): "\(value) is outside 1...60"
        }
    }
}

func parseInterval(_ text: String) throws(IntervalError) -> Int {
    guard let value = Int(text) else { throw .notANumber(text) }
    guard (1...60).contains(value) else { throw .outOfRange(value) }
    return value
}

for input in ["7", "seven", "90"] {
    do {
        let days = try parseInterval(input)
        print("OK: \(days) days")
    } catch {
        // With typed throws, `error` is an IntervalError, not any Error.
        print("Error: \(error)")
    }
}

let maybe = try? parseInterval("12")       // Int? : nil if an error is thrown
print(maybe as Any)

func loadDefault() -> Int {
    defer { print("(defer runs when the scope exits)") }
    return (try? parseInterval("abc")) ?? 7
}
print(loadDefault())
