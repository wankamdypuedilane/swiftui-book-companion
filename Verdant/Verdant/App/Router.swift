import SwiftUI
import VerdantKit

// <router>
/// The navigation state of the whole app: the selected tab and each tab's path.
/// Deep links and notification taps change it from outside the views.
@MainActor
@Observable
final class Router {
    enum TabID: Hashable { case today, garden, catalog, map, settings }

    enum GardenRoute: Hashable {
        case plant(Plant.ID)
    }

    var selectedTab = TabID.today
    var gardenPath: [GardenRoute] = []
    var catalogPath: [Species] = []

    /// Shows the detail of a plant, whatever the app is currently showing.
    func showPlant(_ id: Plant.ID) {
        selectedTab = .garden
        gardenPath = [.plant(id)]
    }

    /// verdant://plants/<uuid> and verdant://catalog
    func handle(_ url: URL) {
        guard url.scheme == "verdant" else { return }
        switch url.host() {
        case "plants":
            if let id = url.pathComponents.dropFirst().first.flatMap(UUID.init(uuidString:)) {
                showPlant(id)
            }
        case "catalog":
            selectedTab = .catalog
            catalogPath = []
        default:
            break
        }
    }
}
// </router>
