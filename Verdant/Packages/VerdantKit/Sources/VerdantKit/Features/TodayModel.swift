import Foundation
import Observation

// <today>
/// The view model of the Today tab: what needs water now, and a summary.
@MainActor
@Observable
public final class TodayModel {
    private let garden: Garden
    private let schedule: WateringSchedule
    private let now: () -> Date

    public init(garden: Garden, schedule: WateringSchedule = WateringSchedule(),
                now: @escaping () -> Date = { .now }) {
        self.garden = garden
        self.schedule = schedule
        self.now = now
    }

    public var thirstyPlants: [Plant] {
        schedule.plantsNeedingWater(garden.plants, on: now())
    }

    public var summary: CareSummary {
        CareSummary(plants: garden.plants, schedule: schedule, on: now())
    }

    public func status(of plant: Plant) -> WateringStatus {
        schedule.status(for: plant, on: now())
    }

    public func water(_ plant: Plant) async {
        await garden.water(plant.id, on: now())
    }

    public func waterAll() async {
        for plant in thirstyPlants {
            await garden.water(plant.id, on: now())
        }
    }
}
// </today>
