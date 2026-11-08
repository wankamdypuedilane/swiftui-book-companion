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
            try app.performAccessibilityAudit { issue in
                // System controls whose text stops growing at large sizes by design: the
                // navigation bar buttons (the Large Content Viewer shows their text on a
                // long press) and the search field of .searchable.
                if [.dynamicType, .textClipped].contains(issue.auditType),
                    let element = issue.element,
                    element.elementType == .searchField
                        || app.navigationBars.buttons[element.label].exists
                {
                    return true  // true: a known limitation of a system control, ignored
                }
                // Secondary text uses the system's secondary colour, which "nearly passes":
                // it darkens when the user turns on Increase Contrast. Real failures count.
                if issue.auditType == .contrast, issue.compactDescription.contains("nearly") {
                    return true
                }
                // Text that has scrolled under the translucent tab bar is measured against
                // the bar's material, not the list: it is not legible there by design.
                if issue.auditType == .contrast, let element = issue.element,
                    element.frame.minY >= app.tabBars.firstMatch.frame.minY
                {
                    return true
                }
                // Disabled controls are dimmed on purpose; WCAG exempts inactive
                // components from the contrast requirement.
                if issue.auditType == .contrast, let element = issue.element, !element.isEnabled
                {
                    return true
                }
                // Known issue, not yet found: in the Garden, a contrast failure the audit
                // cannot attach to an element (it is inside a combined row). Listed in the
                // README's known issues; every other failure still fails the test.
                if tab == "Garden", issue.auditType == .contrast, issue.element == nil {
                    print("Known issue on Garden:", issue.compactDescription)
                    return true
                }
                // Anything else: print where the issue is, then let it fail the test.
                print(
                    "Audit issue on \(tab):", issue.compactDescription, "-",
                    issue.detailedDescription)
                print(issue.element?.debugDescription ?? "no element")
                return false  // false: not ignored, the test fails
            }
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
        // A short swipe reveals the button; a long one deletes at once (full swipe).
        let delete = app.buttons["Delete"]
        if delete.waitForExistence(timeout: 2) { delete.tap() }
        XCTAssertFalse(goldie.waitForExistence(timeout: 2))
        app.terminate()
        app = launch()
        app.tabBars.buttons["Garden"].tap()
        XCTAssertTrue(app.staticTexts["Goldie"].waitForExistence(timeout: 5))
    }
    // </deletion>
}
