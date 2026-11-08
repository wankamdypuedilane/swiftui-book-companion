import Foundation
import Testing
@testable import Sprout

struct SeedlingTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    @Test func ageCountsCalendarDays() {
        let sown = Date(timeIntervalSince1970: 1_767_225_600)  // 2026-01-01 00:00 UTC
        let later = sown.addingTimeInterval(3 * 86_400 + 3_600)
        let seedling = Seedling(variety: "Basil", sownOn: sown, trayPosition: 0)
        #expect(seedling.ageInDays(on: later, calendar: calendar) == 3)
    }

    @Test func trayRowsAreFilledInPositionOrder() {
        let now = Date()
        let seedlings = (0..<5).reversed().map {
            Seedling(variety: "V\($0)", sownOn: now, trayPosition: $0)
        }
        let rows = Seedling.trayRows(seedlings, columns: 2)
        #expect(rows.map { $0.map(\.variety) } == [["V0", "V1"], ["V2", "V3"], ["V4"]])
    }

    @Test func debugBuildsUseTheLocalServer() {
        let url = AppConfiguration.current.apiBaseURL
        #expect(url.absoluteString == "http://localhost:8080")
    }
}
