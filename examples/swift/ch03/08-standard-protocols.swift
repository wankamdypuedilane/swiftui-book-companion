// The compiler can synthesize Equatable, Hashable, Comparable (enums) and Codable.
import Foundation

enum Difficulty: Int, Comparable, Codable, CaseIterable {
    case easy = 1, moderate, demanding
    static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }
}

struct Species: Hashable, Codable, Identifiable {
    let id: String
    let commonName: String
    let difficulty: Difficulty
}

let pothos = Species(id: "pothos", commonName: "Golden pothos", difficulty: .easy)
let calathea = Species(id: "calathea", commonName: "Calathea", difficulty: .demanding)
print(pothos == calathea, Set([pothos, pothos, calathea]).count)
print([calathea, pothos].sorted { $0.difficulty < $1.difficulty }.map(\.commonName))
print(Difficulty.allCases.max()!)

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let json = try encoder.encode(pothos)
print(String(decoding: json, as: UTF8.self))
let back = try JSONDecoder().decode(Species.self, from: json)
print(back == pothos)
