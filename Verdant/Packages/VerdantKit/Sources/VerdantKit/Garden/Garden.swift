import Foundation
import Observation

// <garden>
/// The single source of truth for the user's plants. Views observe it; every
/// change is saved through the injected store.
@MainActor
@Observable
public final class Garden {
    public private(set) var plants: [Plant] = []
    public private(set) var isLoaded = false
    public private(set) var lastError: String?

    @ObservationIgnored private let store: any PlantStore

    public init(store: any PlantStore) {
        self.store = store
    }

    public func load() async {
        do {
            plants = try await store.load()
            lastError = nil
        } catch {
            lastError = "Your garden could not be loaded."
        }
        isLoaded = true
    }

    public func plant(withID id: Plant.ID) -> Plant? {
        plants.first { $0.id == id }
    }

    public func add(_ plant: Plant) async {
        plants.append(plant)
        await persist()
    }

    public func update(_ plant: Plant) async {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index] = plant
        await persist()
    }

    public func delete(_ ids: Set<Plant.ID>) async {
        plants.removeAll { ids.contains($0.id) }
        await persist()
    }

    public func water(_ id: Plant.ID, on date: Date = .now) async {
        guard let index = plants.firstIndex(where: { $0.id == id }) else { return }
        plants[index].record(CareEvent(kind: .watered, date: date))
        await persist()
    }

    public func toggleFavorite(_ id: Plant.ID) async {
        guard let index = plants.firstIndex(where: { $0.id == id }) else { return }
        plants[index].isFavorite.toggle()
        await persist()
    }

    /// Replaces every plant, for example after downloading a backup.
    public func replaceAll(with newPlants: [Plant]) async {
        plants = newPlants
        await persist()
    }

    private func persist() async {
        do {
            try await store.save(plants)
            lastError = nil
        } catch {
            lastError = "Your last change could not be saved."
        }
    }
}
// </garden>
