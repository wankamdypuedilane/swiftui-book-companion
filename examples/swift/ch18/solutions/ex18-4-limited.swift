// Exercise 18.4: at most two requests at a time (start book-api first).
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Species: Decodable, Sendable { let commonName: String }

/// Records how many requests run at the same time.
actor Gauge {
    private(set) var current = 0
    private(set) var maximum = 0
    func enter() { current += 1; maximum = max(maximum, current) }
    func leave() { current -= 1 }
}

func fetchSpecies(_ ids: [String], limit: Int, gauge: Gauge) async throws -> [String: Species] {
    let base = URL(string: "http://localhost:8080/verdant/v1/species/")!
    return try await withThrowingTaskGroup(of: (String, Species).self) { group in
        var pending = ids[...]
        func addNext() {
            guard let id = pending.popFirst() else { return }
            group.addTask {
                await gauge.enter()
                let url = base.appendingPathComponent(id)
                    .appending(queryItems: [URLQueryItem(name: "delay", value: "100")])
                let (data, _) = try await URLSession.shared.data(from: url)
                await gauge.leave()
                return (id, try JSONDecoder().decode(Species.self, from: data))
            }
        }
        for _ in 0..<limit { addNext() }  // start `limit` requests
        var results: [String: Species] = [:]
        for try await (id, species) in group {
            results[id] = species
            addNext()  // one finished: start the next
        }
        return results
    }
}

let ids = [
    "aloe-vera", "hoya-carnosa", "ficus-elastica", "pilea-peperomioides",
    "citrus-limon", "mentha-spicata",
]
let gauge = Gauge()
let results = try await fetchSpecies(ids, limit: 2, gauge: gauge)
print(ids.map { results[$0]!.commonName })
print("Maximum simultaneous requests:", await gauge.maximum)
