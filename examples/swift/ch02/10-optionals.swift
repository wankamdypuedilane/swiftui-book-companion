// Optionals, optional binding, guard and optional chaining.
let nicknames: [String: String] = ["monstera": "Monty", "pothos": "Goldie"]

let a: String? = nicknames["monstera"]
let b = nicknames["ficus"]  // String? that is nil
print(a as Any, b as Any)

if let a { print("Found \(a)") }  // shorthand binding (Swift 5.7)
if let name = nicknames["pothos"], name.count > 3 { print("\(name) is a long name") }
print(b ?? "no nickname")  // nil-coalescing

struct Pot { var diameterCm: Int? }
struct Plant { var name: String; var pot: Pot? }
let plants = [Plant(name: "Fern", pot: Pot(diameterCm: 14)), Plant(name: "Cutting", pot: nil)]
for plant in plants {
    // Optional chaining: the whole expression is nil if any link is nil.
    let size = plant.pot?.diameterCm.map { "\($0) cm" } ?? "no pot"
    print(plant.name, size)
}

func label(forDays text: String) -> String {
    guard let days = Int(text), days > 0 else {
        return "invalid interval"
    }
    return "every \(days) days"  // days is available after the guard
}
print(label(forDays: "7"), "|", label(forDays: "seven"), "|", label(forDays: "0"))
