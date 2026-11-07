import Foundation
import Testing
@testable import VerdantKit

// <tests>
@Suite("Watering schedule")
struct WateringScheduleTests {
    let schedule = WateringSchedule(calendar: utc)

    @Test func nextWateringCountsFromTheLastWatering() {
        let plant = makePlant("Fern", interval: 3, lastWatered: -2)
        #expect(schedule.nextWatering(for: plant) == utc.startOfDay(for: day(1)))
    }

    @Test func plantsNeverWateredCountFromAcquisition() {
        let plant = makePlant("New", interval: 7, acquired: -10)
        #expect(schedule.status(for: plant, on: reference) == .overdue(days: 3))
    }

    @Test(arguments: [(-3, WateringStatus.dueToday),
                      (-1, .upcoming(days: 2)),
                      (-5, .overdue(days: 2))])
    func status(lastWatered: Int, expected: WateringStatus) {
        let plant = makePlant("Fern", interval: 3, lastWatered: lastWatered)
        #expect(schedule.status(for: plant, on: reference) == expected)
    }

    @Test func thirstyPlantsAreSortedByUrgency() {
        let plants = [makePlant("Today", interval: 2, lastWatered: -2),
                      makePlant("Fine", interval: 7, lastWatered: -1),
                      makePlant("Late", interval: 2, lastWatered: -6)]
        let names = schedule.plantsNeedingWater(plants, on: reference).map(\.nickname)
        #expect(names == ["Late", "Today"])
    }

    @Test func statusIgnoresTheTimeOfDay() {
        let plant = makePlant("Fern", interval: 1, lastWatered: -1)
        let lateEvening = reference.addingTimeInterval(15 * 3_600)   // 23:00 UTC
        #expect(schedule.status(for: plant, on: lateEvening) == .dueToday)
    }
}
// </tests>
