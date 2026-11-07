import Foundation
import Testing
@testable import VerdantKit

// <modeltests>
@MainActor
@Suite("View models")
struct FeatureModelTests {
    func loadedGarden(_ plants: [Plant]) async -> Garden {
        let garden = Garden(store: InMemoryPlantStore(plants: plants))
        await garden.load()
        return garden
    }

    @Test func searchMatchesNicknameAndSpeciesIgnoringCase() async {
        var cactus = makePlant("Prickles", interval: 14)
        cactus.speciesName = "Easter lily cactus"
        let garden = await loadedGarden([cactus, makePlant("Fern", interval: 3)])
        let model = GardenListModel(garden: garden, schedule: .init(calendar: utc)) {
            reference
        }
        model.searchText = "LILY"
        #expect(model.visiblePlants.map(\.nickname) == ["Prickles"])
        model.searchText = "fer"
        #expect(model.visiblePlants.map(\.nickname) == ["Fern"])
    }

    @Test func sectionsFollowTheRoomOrder() async {
        let garden = await loadedGarden([
            makePlant("Basil", interval: 2, room: .kitchen),
            makePlant("Monty", interval: 7, room: .livingRoom),
            makePlant("Thyme", interval: 3, room: .kitchen),
        ])
        let model = GardenListModel(garden: garden, schedule: .init(calendar: utc)) {
            reference
        }
        model.sortOrder = .name
        #expect(model.sections.map(\.room) == [.livingRoom, .kitchen])
        #expect(model.sections[1].plants.map(\.nickname) == ["Basil", "Thyme"])
    }

    @Test func editorRefusesToSaveAnInvalidDraft() async {
        let garden = await loadedGarden([])
        let editor = PlantEditorModel(garden: garden) { reference }
        #expect(editor.visibleIssues.isEmpty)  // nothing shown before saving
        #expect(await editor.save() == nil)
        #expect(editor.visibleIssues.contains(.nicknameTooShort))
        #expect(editor.visibleIssues.contains(.speciesMissing))
        #expect(garden.plants.isEmpty)
    }

    @Test func editorUpdatesAnExistingPlant() async throws {
        let fern = makePlant("Fern", interval: 3)
        let garden = await loadedGarden([fern])
        let editor = PlantEditorModel(garden: garden, plant: fern) { reference }
        #expect(!editor.hasChanges)
        editor.draft.nickname = "  Fernanda "
        editor.draft.wateringIntervalDays = 4
        #expect(editor.hasChanges)
        let saved = try #require(await editor.save())
        #expect(saved.id == fern.id)
        #expect(garden.plants == [saved])
        #expect(saved.nickname == "Fernanda")
    }

    @Test func summaryCountsInOnePass() {
        let plants = [
            makePlant("A", interval: 2, lastWatered: -3, room: .kitchen, favorite: true),
            makePlant("B", interval: 7, lastWatered: -1, room: .kitchen),
            makePlant("C", interval: 7, lastWatered: -10, room: .office),
        ]
        let summary = CareSummary(plants: plants, schedule: .init(calendar: utc), on: reference)
        #expect(summary.plantCount == 3)
        #expect(summary.thirstyCount == 2)
        #expect(summary.favoriteCount == 1)
        #expect(summary.wateringsThisWeek == 2)
        #expect(summary.busiestRoom == .kitchen)
    }

    @Test func remindersAreNeverInThePast() {
        let planner = ReminderPlanner(schedule: .init(calendar: utc), hour: 9)
        let plants = [
            makePlant("Due later", interval: 7, lastWatered: -2),
            makePlant("Overdue", interval: 2, lastWatered: -5),
        ]
        let requests = planner.requests(for: plants, now: reference)  // 08:00 UTC
        #expect(requests.map(\.title) == ["Time to water Overdue", "Time to water Due later"])
        #expect(requests[0].fireDate == reference.addingTimeInterval(3_600))  // 09:00 today
        #expect(requests.allSatisfy { $0.fireDate > reference })
    }
}
// </modeltests>
