import SwiftUI
import VerdantKit

// <garden>
/// The Garden tab: every plant, grouped by room, searchable and filterable.
struct GardenView: View {
    @Environment(Garden.self) private var garden
    @Environment(Router.self) private var router
    @State private var model: GardenListModel?
    @State private var isAddingPlant = false

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.gardenPath) {
            Group {
                if let model {
                    GardenList(model: model, isAddingPlant: $isAddingPlant)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Garden")
            .navigationDestination(for: Router.GardenRoute.self) { route in
                switch route {
                case .plant(let id):
                    PlantDetailView(plantID: id)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add plant", systemImage: "plus") { isAddingPlant = true }
                        .accessibilityIdentifier("garden.add")
                }
            }
            .sheet(isPresented: $isAddingPlant) {
                PlantEditorView(model: PlantEditorModel(garden: garden))
            }
        }
        .task {
            if model == nil { model = GardenListModel(garden: garden) }
        }
    }
}
// </garden>

// <gardenlist>
private struct GardenList: View {
    @Bindable var model: GardenListModel
    @Binding var isAddingPlant: Bool

    var body: some View {
        List {
            ForEach(model.sections) { section in
                Section {
                    ForEach(section.plants) { plant in
                        NavigationLink(value: Router.GardenRoute.plant(plant.id)) {
                            PlantRow(plant: plant, status: model.status(of: plant))
                        }
                        .swipeActions(edge: .leading) {
                            Button("Water", systemImage: "drop.fill") {
                                Task { await model.water(plant) }
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                Task { await model.delete([plant]) }
                            }
                        }
                        .contextMenu {
                            Button(
                                plant.isFavorite
                                    ? "Remove from favourites" : "Add to favourites",
                                systemImage: plant.isFavorite ? "star.slash" : "star"
                            ) {
                                Task { await model.toggleFavorite(plant) }
                            }
                            Button("Water", systemImage: "drop") {
                                Task { await model.water(plant) }
                            }
                        }
                    }
                } header: {
                    Label(section.room.title, systemImage: section.room.symbolName)
                }
            }
        }
        .overlay { emptyState }
        .searchable(text: $model.searchText, prompt: "Name or species")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { filterMenu }
        }
        .animation(.default, value: model.sections)
    }

    @ViewBuilder
    private var emptyState: some View {
        if model.isGardenEmpty {
            ContentUnavailableView {
                Label("No plants yet", systemImage: "leaf")
            } description: {
                Text("Add the plants you keep at home to start tracking their care.")
            } actions: {
                Button("Add a plant") { isAddingPlant = true }
                    .buttonStyle(.borderedProminent)
            }
        } else if model.hasNoResults {
            if model.searchText.isEmpty {
                ContentUnavailableView(
                    "No matching plants", systemImage: "line.3.horizontal.decrease",
                    description: Text("Try another room or show all plants."))
            } else {
                ContentUnavailableView.search(text: model.searchText)
            }
        }
    }

    private var filterMenu: some View {
        Menu("Filter", systemImage: "line.3.horizontal.decrease.circle") {
            Picker("Sort by", selection: $model.sortOrder) {
                ForEach(GardenListModel.SortOrder.allCases) { Text($0.title).tag($0) }
            }
            Picker("Room", selection: $model.roomFilter) {
                Text("All rooms").tag(Room?.none)
                ForEach(Room.allCases) { room in
                    Label(room.title, systemImage: room.symbolName).tag(Room?.some(room))
                }
            }
            Toggle("Favourites only", systemImage: "star", isOn: $model.showsFavoritesOnly)
        }
    }
}
// </gardenlist>
