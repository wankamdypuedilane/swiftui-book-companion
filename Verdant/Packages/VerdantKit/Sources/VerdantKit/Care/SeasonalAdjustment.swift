import Foundation

// <seasonal>
/// Most house plants grow slowly in winter and need water less often.
/// Written test-first: see SeasonalAdjustmentTests.
public struct SeasonalAdjustment: Sendable {
    /// Months (1...12) in which intervals are lengthened.
    public var restMonths: Set<Int>
    /// The interval is multiplied by this factor during the rest months.
    public var factor: Double

    public init(restMonths: Set<Int> = [11, 12, 1, 2], factor: Double = 1.5) {
        self.restMonths = restMonths
        self.factor = factor
    }

    public func interval(_ days: Int, inMonth month: Int) -> Int {
        guard restMonths.contains(month) else { return days }
        return min(60, Int((Double(days) * factor).rounded(.up)))
    }
}
// </seasonal>
