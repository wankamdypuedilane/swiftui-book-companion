import Foundation
import SwiftData
import Testing
import VerdantKit
@testable import Verdant

// <swiftdatatests>
@Suite("SwiftData store")
struct SwiftDataPlantStoreTests {
    /// A container that lives in memory only: every test starts from an empty database.
    func makeStore() throws -> SwiftDataPlantStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: PlantRecord.self, CareEventRecord.self,
            configurations: configuration)
        return SwiftDataPlantStore(modelContainer: container)
    }

    @Test func savesAndLoadsPlantsWithTheirHistory() async throws {
        let store = try makeStore()
        let plants = SampleData.garden()
        try await store.save(plants)
        let loaded = try await store.load()
        #expect(loaded.count == plants.count)
        let monty = try #require(loaded.first { $0.nickname == "Monty" })
        let original = try #require(plants.first { $0.nickname == "Monty" })
        #expect(monty == original)  // including the sorted care log
    }

    @Test func savingAGardenDeletesRemovedPlants() async throws {
        let store = try makeStore()
        var plants = SampleData.garden()
        try await store.save(plants)
        plants.removeFirst()
        plants[0].careLog.removeAll()
        try await store.save(plants)
        let loaded = try await store.load()
        #expect(loaded.count == plants.count)
        #expect(loaded.first { $0.id == plants[0].id }?.careLog.isEmpty == true)
    }
}
// </swiftdatatests>
