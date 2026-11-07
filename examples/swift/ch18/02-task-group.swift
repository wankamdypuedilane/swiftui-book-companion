// A task group fetches several resources concurrently (start book-api first).
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Species: Decodable, Sendable { let commonName: String; let wateringDays: Int }

// <group>
func fetchSpecies(_ ids: [String]) async throws -> [String: Species] {
    let base = URL(string: "http://localhost:8080/verdant/v1/species/")!
    return try await withThrowingTaskGroup(of: (String, Species).self) { group in
        for id in ids {
            group.addTask {  // one child task per species
                let (data, _) = try await URLSession.shared.data(
                    from: base.appendingPathComponent(id))
                return (id, try JSONDecoder().decode(Species.self, from: data))
            }
        }
        var results: [String: Species] = [:]
        for try await (id, species) in group {  // in order of completion
            results[id] = species
        }
        return results
    }
}

let ids = ["aloe-vera", "monstera-deliciosa", "ocimum-basilicum", "hoya-carnosa"]
let catalogue = try await fetchSpecies(ids)
for id in ids {  // print in a stable order
    print(id, "->", catalogue[id]!.commonName, "every", catalogue[id]!.wateringDays, "days")
}
// </group>
