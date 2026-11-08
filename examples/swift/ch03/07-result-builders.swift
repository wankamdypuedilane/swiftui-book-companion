// A result builder turns a block of statements into a value, like SwiftUI's ViewBuilder.
@resultBuilder
enum ChecklistBuilder {
    static func buildExpression(_ item: String) -> [String] { [item] }
    static func buildBlock(_ parts: [String]...) -> [String] { parts.flatMap { $0 } }
    static func buildOptional(_ part: [String]?) -> [String] { part ?? [] }
    static func buildEither(first part: [String]) -> [String] { part }
    static func buildEither(second part: [String]) -> [String] { part }
    static func buildArray(_ parts: [[String]]) -> [String] { parts.flatMap { $0 } }
}

func checklist(@ChecklistBuilder _ content: () -> [String]) -> String {
    content().enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
}

let isSummer = true
let plants = ["Fern", "Basil"]
let list = checklist {
    "Check soil moisture"
    if isSummer { "Close the blinds at noon" } else { "Move pots away from the radiator" }
    for plant in plants { "Inspect \(plant) leaves" }
    "Empty the saucers"
}
print(list)
