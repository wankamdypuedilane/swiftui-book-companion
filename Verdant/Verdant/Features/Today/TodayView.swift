import SwiftUI
import VerdantKit

// <today>
struct TodayView: View {
    @Environment(Garden.self) private var garden
    @State private var model: TodayModel?

    var body: some View {
        NavigationStack {
            Group {
                if let model {
                    TodayContent(model: model)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Today")
        }
        .task {
            // The view model needs the garden from the environment, which is not
            // available in init: create it the first time the view appears.
            if model == nil { model = TodayModel(garden: garden) }
        }
    }
}

private struct TodayContent: View {
    let model: TodayModel

    var body: some View {
        let summary = model.summary
        List {
            Section {
                HStack(spacing: 12) {
                    StatTile(value: summary.plantCount, label: "Plants", systemImage: "leaf.fill")
                    StatTile(value: summary.thirstyCount, label: "Thirsty", systemImage: "drop.fill")
                    StatTile(value: summary.wateringsThisWeek, label: "This week",
                             systemImage: "calendar")
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                if model.thirstyPlants.isEmpty {
                    ContentUnavailableView("All watered", systemImage: "checkmark.circle",
                                           description: Text("No plant needs water today."))
                } else {
                    ForEach(model.thirstyPlants) { plant in
                        HStack {
                            PlantRow(plant: plant, status: model.status(of: plant))
                            Button("Water", systemImage: "drop.fill") {
                                Task { await model.water(plant) }
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderedProminent)
                            .accessibilityLabel("Water \(plant.nickname)")
                        }
                    }
                }
            } header: {
                Text("Needs water")
            }
        }
        .animation(.default, value: model.thirstyPlants)
        .toolbar {
            if model.thirstyPlants.count > 1 {
                Button("Water all") { Task { await model.waterAll() } }
            }
        }
    }
}
// </today>

#Preview {
    TodayView().environment(AppDependencies.preview.garden)
        .task { await AppDependencies.preview.garden.load() }
}
