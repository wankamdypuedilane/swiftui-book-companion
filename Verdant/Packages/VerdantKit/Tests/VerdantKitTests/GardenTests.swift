import Foundation
import Testing
@testable import VerdantKit

// <gardentests>
@MainActor
@Suite("Garden")
struct GardenTests {
    @Test func loadsWhatTheStoreContains() async {
        let store = InMemoryPlantStore(plants: [makePlant("Fern", interval: 3)])
        let garden = Garden(store: store)
        await garden.load()
        #expect(garden.plants.map(\.nickname) == ["Fern"])
        #expect(garden.isLoaded)
    }

    @Test func everyChangeIsSaved() async throws {
        let store = InMemoryPlantStore()
        let garden = Garden(store: store)
        let fern = makePlant("Fern", interval: 3)
        await garden.add(fern)
        await garden.water(fern.id, on: reference)
        await garden.toggleFavorite(fern.id)
        #expect(await store.saveCount == 3)
        let saved = try #require(try await store.load().first)
        #expect(saved.lastWatered == reference)
        #expect(saved.isFavorite)
    }

    @Test func deleteRemovesOnlyTheGivenPlants() async {
        let a = makePlant("A", interval: 1), b = makePlant("B", interval: 1)
        let garden = Garden(store: InMemoryPlantStore(plants: [a, b]))
        await garden.load()
        await garden.delete([a.id])
        #expect(garden.plants.map(\.nickname) == ["B"])
    }

    @Test func fileStoreRoundTrip() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("verdant-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = JSONFilePlantStore(fileURL: url)
        #expect(try await store.load().isEmpty)              // no file yet
        let plants = SampleData.garden(reference: reference, calendar: utc)
        try await store.save(plants)
        #expect(try await store.load() == plants)
    }
}
// </gardentests>
