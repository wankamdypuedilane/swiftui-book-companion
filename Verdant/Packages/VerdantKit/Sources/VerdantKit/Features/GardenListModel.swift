import Foundation
import Observation

// <listmodel>
/// The view model of the Garden tab: search, filter, sort and group the plants.
@MainActor
@Observable
public final class GardenListModel {
    public enum SortOrder: String, CaseIterable, Identifiable, Sendable {
        case name, nextWatering, recentlyAdded
        public var id: Self { self }
        public var title: String {
            switch self {
            case .name: "Name"
            case .nextWatering: "Next watering"
            case .recentlyAdded: "Recently added"
            }
        }
    }

    public struct RoomSection: Identifiable, Equatable {
        public let room: Room
        public let plants: [Plant]
        public var id: Room { room }
    }

    public var searchText = ""
    public var roomFilter: Room?
    public var sortOrder = SortOrder.nextWatering
    public var showsFavoritesOnly = false

    private let garden: Garden
    private let schedule: WateringSchedule
    private let now: () -> Date

    public init(garden: Garden, schedule: WateringSchedule = WateringSchedule(),
                now: @escaping () -> Date = { .now }) {
        self.garden = garden
        self.schedule = schedule
        self.now = now
    }

    /// The plants that match the search and the filters, in the chosen order.
    public var visiblePlants: [Plant] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        let today = now()
        return garden.plants
            .filter { roomFilter == nil || $0.room == roomFilter }
            .filter { !showsFavoritesOnly || $0.isFavorite }
            .filter {
                query.isEmpty
                    || $0.nickname.localizedStandardContains(query)
                    || $0.speciesName.localizedStandardContains(query)
            }
            .sorted { lhs, rhs in
                switch sortOrder {
                case .name:
                    lhs.nickname.localizedStandardCompare(rhs.nickname) == .orderedAscending
                case .nextWatering:
                    schedule.status(for: lhs, on: today).daysUntilDue
                        < schedule.status(for: rhs, on: today).daysUntilDue
                case .recentlyAdded:
                    lhs.acquiredOn > rhs.acquiredOn
                }
            }
    }

    /// The visible plants grouped by room, rooms in their declaration order.
    public var sections: [RoomSection] {
        let grouped = Dictionary(grouping: visiblePlants, by: \.room)
        return Room.allCases.compactMap { room in
            grouped[room].map { RoomSection(room: room, plants: $0) }
        }
    }

    public var isGardenEmpty: Bool { garden.isLoaded && garden.plants.isEmpty }
    public var hasNoResults: Bool { !garden.plants.isEmpty && visiblePlants.isEmpty }

    public func status(of plant: Plant) -> WateringStatus {
        schedule.status(for: plant, on: now())
    }

    public func delete(_ plants: [Plant]) async {
        await garden.delete(Set(plants.map(\.id)))
    }

    public func water(_ plant: Plant) async {
        await garden.water(plant.id, on: now())
    }

    public func toggleFavorite(_ plant: Plant) async {
        await garden.toggleFavorite(plant.id)
    }
}
// </listmodel>
