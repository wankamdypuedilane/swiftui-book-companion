import SwiftUI
import VerdantKit

// <tabs>
/// The main interface: five tabs, each with its own navigation stack.
struct MainTabView: View {
    @Environment(Router.self) private var router
    @Environment(Garden.self) private var garden

    var body: some View {
        @Bindable var router = router                  // bindings to an observable object
        TabView(selection: $router.selectedTab) {
            Tab("Today", systemImage: "sun.max", value: Router.TabID.today) {
                TodayView()
            }
            .badge(thirstyCount)

            Tab("Garden", systemImage: "leaf", value: Router.TabID.garden) {
                GardenView()
            }

            Tab("Catalogue", systemImage: "books.vertical", value: Router.TabID.catalog) {
                CatalogView()
            }

            Tab("Map", systemImage: "map", value: Router.TabID.map) {
                PlacesMapView()
            }

            Tab("Settings", systemImage: "gearshape", value: Router.TabID.settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)                  // a sidebar on iPad, tabs on iPhone
    }

    private var thirstyCount: Int {
        WateringSchedule().plantsNeedingWater(garden.plants, on: .now).count
    }
}
// </tabs>
