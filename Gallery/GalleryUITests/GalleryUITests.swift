import XCTest

/// Opens every example of the gallery: each screen must appear without crashing.
final class GalleryUITests: XCTestCase {
    @MainActor
    func testEveryExampleOpens() {
        var index = 0
        while true {
            let app = XCUIApplication()
            app.launchArguments = ["-openExample", String(index)]
            app.launch()
            if app.staticTexts["No more examples"].waitForExistence(timeout: 2) { break }
            XCTAssertTrue(
                app.navigationBars.firstMatch.waitForExistence(timeout: 10),
                "Example \(index) did not open")
            XCTAssertEqual(app.state, .runningForeground, "Example \(index) crashed")
            let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            screenshot.name = "gallery-\(index)"
            screenshot.lifetime = .keepAlways  // exported by CI for the book's figures
            add(screenshot)
            index += 1
        }
        print("Opened \(index) examples")
        XCTAssertGreaterThan(index, 0)
    }
}
