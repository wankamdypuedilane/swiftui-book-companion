// Exercise 2.2: statistics about a list of plant names.
let names = ["Fern", "Pothos", "Calathea", "Ivy", "Fern", "Peace lily", "Pothos", "Fern"]

var frequency: [String: Int] = [:]
for name in names { frequency[name, default: 0] += 1 }

let unique = Set(names)
let longest = names.max { $0.count < $1.count } ?? ""
let mostCommon = frequency.max { a, b in
    a.value < b.value || (a.value == b.value && a.key > b.key)
}

print("Names: \(names.count), unique: \(unique.count)")
print("Longest: \(longest)")
if let mostCommon { print("Most common: \(mostCommon.key) (\(mostCommon.value) times)") }
for name in frequency.keys.sorted() { print("  \(name): \(frequency[name]!)") }
