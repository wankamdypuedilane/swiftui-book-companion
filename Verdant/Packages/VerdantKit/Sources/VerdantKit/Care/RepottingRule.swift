import Foundation

/// Exercise 21.3: a plant needs repotting when it has stayed more than two
/// years in the same pot (since its last repotting, or since it was acquired).
public struct RepottingRule: Sendable {
    public var calendar: Calendar
    public var years = 2

    public init(calendar: Calendar = .current) { self.calendar = calendar }

    public func needsRepotting(_ plant: Plant, today: Date) -> Bool {
        let lastRepotting = plant.careLog.first { $0.kind == .repotted }?.date
        let start = lastRepotting ?? plant.acquiredOn
        guard let due = calendar.date(byAdding: .year, value: years, to: start) else {
            return false
        }
        return today > due
    }
}
