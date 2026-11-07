import Foundation

// <summary>
/// Figures shown on the Today screen, computed from the plants in one pass.
public struct CareSummary: Equatable, Sendable {
    public var plantCount = 0
    public var thirstyCount = 0
    public var favoriteCount = 0
    public var wateringsThisWeek = 0
    public var plantsPerRoom: [Room: Int] = [:]

    public init() {}

    public init(plants: [Plant], schedule: WateringSchedule, on date: Date) {
        let weekAgo = schedule.calendar.date(byAdding: .day, value: -7, to: date) ?? date
        self = plants.reduce(into: CareSummary()) { summary, plant in
            summary.plantCount += 1
            if schedule.status(for: plant, on: date).needsWater { summary.thirstyCount += 1 }
            if plant.isFavorite { summary.favoriteCount += 1 }
            summary.wateringsThisWeek += plant.careLog.count(where: {
                $0.kind == .watered && $0.date > weekAgo && $0.date <= date
            })
            summary.plantsPerRoom[plant.room, default: 0] += 1
        }
    }

    /// The room with the most plants (alphabetical order breaks ties).
    public var busiestRoom: Room? {
        plantsPerRoom.max { a, b in
            a.value != b.value ? a.value < b.value : a.key.title > b.key.title
        }?.key
    }
}
// </summary>
