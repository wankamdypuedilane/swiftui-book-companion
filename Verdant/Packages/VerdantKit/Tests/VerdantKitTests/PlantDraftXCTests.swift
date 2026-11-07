import XCTest
@testable import VerdantKit

// <xctest>
/// The same kind of tests written with XCTest, the older framework: a class,
/// methods whose names start with "test", and XCTAssert functions.
final class PlantDraftXCTests: XCTestCase {
    private var today: Date!

    override func setUp() {
        super.setUp()
        today = Date(timeIntervalSince1970: 1_793_520_000)  // 1 November 2026
    }

    func testAValidDraftHasNoIssues() {
        var draft = PlantDraft()
        draft.nickname = "Monty"
        draft.speciesName = "Monstera"
        draft.acquiredOn = today
        XCTAssertEqual(draft.issues(today: today, calendar: utc), [])
    }

    func testTheNameIsTrimmedBeforeCounting() {
        var draft = PlantDraft()
        draft.nickname = "  M  "
        draft.speciesName = "Monstera"
        draft.acquiredOn = today
        XCTAssertTrue(draft.issues(today: today, calendar: utc).contains(.nicknameTooShort))
    }

    func testMakePlantKeepsTheIdentityWhenEditing() throws {
        let original = makePlant("Fern", interval: 3, lastWatered: -1)
        var draft = PlantDraft(plant: original)
        draft.wateringIntervalDays = 4
        let edited = draft.makePlant(updating: original)
        XCTAssertEqual(edited.id, original.id)
        XCTAssertEqual(edited.careLog, original.careLog)
        XCTAssertEqual(edited.wateringIntervalDays, 4)
    }
}
// </xctest>
