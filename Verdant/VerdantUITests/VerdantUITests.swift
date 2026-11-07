import XCTest

// <uitests>
/// End-to-end tests: they launch the app in the simulator and drive it like a user.
final class VerdantUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(onboardingDone: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        // "-key value" arguments set UserDefaults values, read by @AppStorage, for this
        // run only: the app cannot override them, so the onboarding test asks the app
        // to store false instead.
        app.launchArguments = ["-uiTesting", "-remindersOn", "NO"]
        app.launchArguments +=
            onboardingDone ? ["-hasCompletedOnboarding", "YES"] : ["-showOnboarding"]
        app.launch()
        return app
    }

    @MainActor
    func testOnboardingLeadsToTheTabs() {
        let app = launch(onboardingDone: false)
        XCTAssertTrue(app.staticTexts["Welcome to Verdant"].waitForExistence(timeout: 5))
        let primary = app.buttons["onboarding.primary"]
        for _ in 0..<3 { primary.tap() }  // Next, Next, Next
        XCTAssertEqual(primary.label, "Get started")
        primary.tap()
        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAddingAPlantValidatesThenSaves() {
        let app = launch()
        app.tabBars.buttons["Garden"].tap()
        app.buttons["garden.add"].tap()
        app.buttons["editor.save"].tap()  // empty form: refused
        XCTAssertTrue(
            app.staticTexts["Give your plant a name of at least 2 characters."]
                .waitForExistence(timeout: 3))
        let name = app.textFields["editor.nickname"]
        name.tap()
        name.typeText("Ziggy")
        let species = app.textFields["editor.species"]
        species.tap()
        species.typeText("ZZ plant")
        app.buttons["editor.save"].tap()
        XCTAssertTrue(app.staticTexts["Ziggy"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testWateringFromTodayEmptiesTheList() {
        let app = launch()
        let waterAll = app.buttons["Water all"]
        XCTAssertTrue(waterAll.waitForExistence(timeout: 5))
        waterAll.tap()
        XCTAssertTrue(app.staticTexts["All watered"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCatalogueLoadsFromTheDemoServer() throws {
        let app = launch()
        app.tabBars.buttons["Catalogue"].tap()
        let aloe = app.staticTexts["Aloe"]
        XCTAssertTrue(
            aloe.waitForExistence(timeout: 15), "Is book-api running on localhost:8080?")
        aloe.tap()
        XCTAssertTrue(app.buttons["Add to my garden"].waitForExistence(timeout: 5))
    }
}
// </uitests>

// <audit>
extension VerdantUITests {
    /// Runs Xcode's automated accessibility audit on the main screens (iOS 17+).
    @MainActor
    func testMainScreensPassTheAccessibilityAudit() throws {
        let app = launch()
        for tab in ["Today", "Garden", "Settings"] {
            app.tabBars.buttons[tab].tap()
            try app.performAccessibilityAudit()
        }
    }
}
// </audit>

extension VerdantUITests {
    /// Exercise 21.4: deleting a plant, then checking that UI tests start fresh.
    // <deletion>
    @MainActor
    func testDeletingAPlant() {
        var app = launch()
        app.tabBars.buttons["Garden"].tap()
        let goldie = app.staticTexts["Goldie"]
        XCTAssertTrue(goldie.waitForExistence(timeout: 5))
        goldie.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(goldie.waitForExistence(timeout: 2))
        app.terminate()
        app = launch()
        app.tabBars.buttons["Garden"].tap()
        XCTAssertTrue(app.staticTexts["Goldie"].waitForExistence(timeout: 5))
    }
    // </deletion>
}
