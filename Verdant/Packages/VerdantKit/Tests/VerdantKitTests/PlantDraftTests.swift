import Foundation
import Testing
@testable import VerdantKit

/// Exercise 21.2: PlantDraftXCTests rewritten with Swift Testing.
@Suite("Plant draft")
struct PlantDraftTests {
    let today = Date(timeIntervalSince1970: 1_793_520_000)  // 1 November 2026
    var draft = PlantDraft()

    init() {
        draft.speciesName = "Monstera"
        draft.acquiredOn = today
    }

    @Test mutating func aValidDraftHasNoIssues() {
        draft.nickname = "Monty"
        #expect(draft.issues(today: today, calendar: utc).isEmpty)
    }

    @Test mutating func theNameIsTrimmedBeforeCounting() {
        draft.nickname = "  M  "
        #expect(draft.issues(today: today, calendar: utc).contains(.nicknameTooShort))
    }

    @Test func makePlantKeepsTheIdentityWhenEditing() {
        let original = makePlant("Fern", interval: 3, lastWatered: -1)
        var edit = PlantDraft(plant: original)
        edit.wateringIntervalDays = 4
        let edited = edit.makePlant(updating: original)
        #expect(edited.id == original.id)
        #expect(edited.careLog == original.careLog)
        #expect(edited.wateringIntervalDays == 4)
    }
}
