import XCTest
final class SmokeUITests: XCTestCase {
    @MainActor func testTapIncrements() {
        let app = XCUIApplication(); app.launch()
        app.buttons["Tap"].tap()
        XCTAssertEqual(app.staticTexts["taps"].label, "Taps: 1")
    }
}
