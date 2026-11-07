import Foundation
import Testing
@testable import VerdantKit

/// Exercise 21.3: written before RepottingRule.
@Suite("Repotting")
struct RepottingTests {
    let rule = RepottingRule(calendar: utc)

    func years(_ value: Int) -> Date {
        utc.date(byAdding: .year, value: -value, to: reference) ?? reference
    }

    @Test func aRecentlyAcquiredPlantDoesNotNeedRepotting() {
        let plant = makePlant("New", interval: 7, acquired: -100)
        #expect(!rule.needsRepotting(plant, today: reference))
    }

    @Test func aPlantNeverRepottedForThreeYearsNeedsIt() {
        var plant = makePlant("Old", interval: 7)
        plant.acquiredOn = years(3)
        #expect(rule.needsRepotting(plant, today: reference))
    }

    @Test func theLastRepottingCountsMoreThanTheAcquisition() {
        var plant = makePlant("Old", interval: 7)
        plant.acquiredOn = years(5)
        plant.record(CareEvent(kind: .repotted, date: years(1)))
        #expect(!rule.needsRepotting(plant, today: reference))
    }

    @Test func exactlyTwoYearsIsNotYetTooLong() {
        var plant = makePlant("Boundary", interval: 7)
        plant.acquiredOn = years(2)
        #expect(!rule.needsRepotting(plant, today: reference))
    }
}
