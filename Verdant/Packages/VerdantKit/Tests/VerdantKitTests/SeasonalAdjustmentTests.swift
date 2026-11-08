import Testing
@testable import VerdantKit

// <tdd>
// These tests were written before SeasonalAdjustment existed (red), then the
// simplest implementation that passes them was written (green), then refined.
@Suite("Seasonal adjustment")
struct SeasonalAdjustmentTests {
    let adjustment = SeasonalAdjustment()

    @Test func summerIntervalsAreUnchanged() {
        #expect(adjustment.interval(7, inMonth: 7) == 7)
    }

    @Test func winterIntervalsAreLonger() {
        #expect(adjustment.interval(7, inMonth: 1) == 11)  // 10.5 rounded up
    }

    @Test(arguments: [2, 3, 7])
    func neverShorter(days: Int) {
        for month in 1...12 {
            #expect(adjustment.interval(days, inMonth: month) >= days)
        }
    }

    @Test func neverMoreThanTheValidRange() {
        #expect(adjustment.interval(50, inMonth: 12) == 60)
    }
}
// </tdd>
