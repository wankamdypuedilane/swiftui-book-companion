import Foundation

// <status>
/// Where a plant stands in its watering cycle on a given day.
public enum WateringStatus: Hashable, Sendable {
    case overdue(days: Int)
    case dueToday
    case upcoming(days: Int)

    /// Negative when overdue, 0 today, positive in the future: sorts by urgency.
    public var daysUntilDue: Int {
        switch self {
        case .overdue(let days): -days
        case .dueToday: 0
        case .upcoming(let days): days
        }
    }

    public var needsWater: Bool { daysUntilDue <= 0 }
}
// </status>

// <schedule>
/// Pure watering rules. Every function takes the date and the calendar it works
/// with, so the results never depend on when or where the code runs.
public struct WateringSchedule: Sendable {
    public var calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// The day the plant should next be watered: the interval counted from the
    /// last watering, or from the day the plant was acquired.
    public func nextWatering(for plant: Plant) -> Date {
        let start = calendar.startOfDay(for: plant.lastWatered ?? plant.acquiredOn)
        return calendar.date(byAdding: .day, value: plant.wateringIntervalDays, to: start) ?? start
    }

    public func status(for plant: Plant, on date: Date) -> WateringStatus {
        let today = calendar.startOfDay(for: date)
        let due = nextWatering(for: plant)
        let days = calendar.dateComponents([.day], from: today, to: due).day ?? 0
        if days < 0 { return .overdue(days: -days) }
        return days == 0 ? .dueToday : .upcoming(days: days)
    }

    /// Plants that need water on `date`, the most overdue first.
    public func plantsNeedingWater(_ plants: [Plant], on date: Date) -> [Plant] {
        plants
            .map { (plant: $0, status: status(for: $0, on: date)) }
            .filter { $0.status.needsWater }
            .sorted { ($0.status.daysUntilDue, $0.plant.nickname) < ($1.status.daysUntilDue, $1.plant.nickname) }
            .map(\.plant)
    }
}
// </schedule>
