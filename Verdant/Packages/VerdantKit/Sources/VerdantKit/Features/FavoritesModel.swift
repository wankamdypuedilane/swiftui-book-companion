import Foundation
import Observation

// <favorites>
/// Exercise 13.4: the favourite plants, soonest watering first.
@MainActor
@Observable
public final class FavoritesModel {
    private let garden: Garden
    private let schedule: WateringSchedule

    public init(garden: Garden, schedule: WateringSchedule = WateringSchedule()) {
        self.garden = garden
        self.schedule = schedule
    }

    /// Computed from the Garden on every read: nothing to keep in sync.
    public var favorites: [Plant] {
        garden.plants
            .filter(\.isFavorite)
            .sorted { schedule.nextWatering(for: $0) < schedule.nextWatering(for: $1) }
    }

    public func unfavorite(_ plant: Plant) async {
        await garden.toggleFavorite(plant.id)
    }
}
// </favorites>
