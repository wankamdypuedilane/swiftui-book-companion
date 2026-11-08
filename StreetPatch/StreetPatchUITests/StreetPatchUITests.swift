import XCTest

/// End-to-end tests against the demonstration API (book-api) running on this Mac.
final class StreetPatchUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        return app
    }

    @MainActor
    private func signIn(_ app: XCUIApplication) {
        app.tabBars.buttons["Mine"].tap()
        app.buttons["mine.signIn"].tap()
        let email = app.textFields["signIn.email"]
        XCTAssertTrue(email.waitForExistence(timeout: 5))
        email.tap()
        email.typeText("resident@streetpatch.example")
        let password = app.secureTextFields["signIn.password"]
        password.tap()
        password.typeText("local-only-demo-password")
        app.buttons["signIn.submit"].tap()
        XCTAssertTrue(app.buttons["Sign out"].waitForExistence(timeout: 10))
        // A signed app has AutoFill: iOS may offer to save the password, in a sheet that
        // covers the app. Decline it.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for notNow in [app.buttons["Not Now"], springboard.buttons["Not Now"]]
        where notNow.waitForExistence(timeout: 3) {
            notNow.tap()
        }
    }

    // <uitests>
    @MainActor
    func testBrowsingNeedsNoAccount() {
        let app = launch()
        app.tabBars.buttons["List"].tap()
        let report = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Deep pothole at the bus stop")
        ).firstMatch
        XCTAssertTrue(report.waitForExistence(timeout: 10))
        attachScreenshot(of: app, named: "streetpatch-list")
        report.tap()
        XCTAssertTrue(app.staticTexts["Progress"].waitForExistence(timeout: 5))
        attachScreenshot(of: app, named: "streetpatch-detail")
    }

    @MainActor
    func testReportingAProblemThenWithdrawingIt() throws {
        let app = launch()
        signIn(app)
        // Both the Map and the List tab have this button in their navigation bar; the
        // hidden tab's copy can stay in the hierarchy, so take the one that can be tapped.
        app.tabBars.buttons["List"].tap()
        let buttons = app.buttons.matching(identifier: "report.new")
        XCTAssertTrue(buttons.firstMatch.waitForExistence(timeout: 10))
        let button = try XCTUnwrap(buttons.allElementsBoundByIndex.first(where: \.isHittable))
        button.tap()
        if !app.buttons["composer.send"].waitForExistence(timeout: 5) {
            print(app.debugDescription)  // what opened instead of the form
        }

        // Sending an empty form shows the problems instead of sending.
        app.buttons["composer.send"].tap()
        XCTAssertTrue(
            app.staticTexts["Describe the problem in at least 5 characters."]
                .waitForExistence(timeout: 5))

        let title = app.textFields["composer.title"]
        title.tap()
        title.typeText("Bench with a missing slat")
        attachScreenshot(of: app, named: "streetpatch-composer")
        app.buttons["composer.send"].tap()

        app.tabBars.buttons["Mine"].tap()
        let sent = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Bench with a missing slat")
        ).firstMatch
        XCTAssertTrue(sent.waitForExistence(timeout: 10))
        attachScreenshot(of: app, named: "streetpatch-mine")

        sent.tap()
        app.buttons["detail.withdraw"].tap()
        app.buttons["Withdraw"].tap()  // the confirmation dialog
        XCTAssertTrue(app.navigationBars["Mine"].waitForExistence(timeout: 10))
        XCTAssertFalse(sent.waitForExistence(timeout: 2))
    }

    @MainActor
    func testMainScreensPassTheAccessibilityAudit() throws {
        let app = launch()
        for tab in ["List", "Mine"] {
            app.tabBars.buttons[tab].tap()
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 5)
            try app.performAccessibilityAudit { issue in
                // Secondary text uses the system's secondary colour, which "nearly passes":
                // it darkens when the user turns on Increase Contrast. Real failures count.
                if issue.auditType == .contrast, issue.compactDescription.contains("nearly") {
                    return true
                }
                // Print where the issue is, then let it fail the test.
                print(
                    "Audit issue on \(tab):", issue.compactDescription, "-",
                    issue.detailedDescription)
                print(issue.element?.debugDescription ?? "no element")
                return false  // false: not ignored, the test fails
            }
        }
    }
    // </uitests>

    @MainActor
    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
