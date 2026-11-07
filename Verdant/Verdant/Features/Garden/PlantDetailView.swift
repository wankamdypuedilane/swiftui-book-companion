import SwiftUI
import VerdantKit

// <detail>
/// The detail of one plant. It receives an identifier, not a copy: it always
/// shows the current state of the plant in the garden.
struct PlantDetailView: View {
    let plantID: Plant.ID
    @Environment(Garden.self) private var garden
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var isConfirmingDeletion = false

    private let schedule = WateringSchedule()

    var body: some View {
        if let plant = garden.plant(withID: plantID) {
            content(for: plant)
        } else {
            ContentUnavailableView(
                "Plant not found", systemImage: "leaf",
                description: Text("It may have been deleted."))
        }
    }

    private func content(for plant: Plant) -> some View {
        List {
            Section {
                LabeledContent("Species", value: plant.speciesName)
                LabeledContent("Room") {
                    Label(plant.room.title, systemImage: plant.room.symbolName)
                }
                LabeledContent("Light") {
                    Label(plant.light.title, systemImage: plant.light.symbolName)
                }
                LabeledContent("Water every", value: "\(plant.wateringIntervalDays) days")
                LabeledContent("Next watering") {
                    Text(
                        schedule.nextWatering(for: plant),
                        format: .dateTime.weekday(.wide).day().month())
                }
                LabeledContent("At home since") {
                    Text(plant.acquiredOn, format: .dateTime.day().month().year())
                }
            }

            Section {
                Button {
                    Task { await garden.water(plant.id) }
                } label: {
                    Label("Water now", systemImage: "drop.fill")
                }
                .accessibilityIdentifier("detail.water")
            }

            if !plant.notes.isEmpty {
                Section("Notes") { Text(plant.notes) }
            }

            Section("Care history") {
                CareLogView(events: plant.careLog)
            }
        }
        .navigationTitle(plant.nickname)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isEditing = true }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    isConfirmingDeletion = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            PlantEditorView(model: PlantEditorModel(garden: garden, plant: plant))
        }
        .confirmationDialog(
            "Delete \(plant.nickname)?", isPresented: $isConfirmingDeletion,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await garden.delete([plant.id])
                    dismiss()
                }
            }
        } message: {
            Text("Its care history will be deleted too.")
        }
    }
}
// </detail>

#Preview {
    let garden = AppDependencies.preview.garden
    NavigationStack {
        PlantDetailView(plantID: SampleData.garden()[0].id)
    }
    .environment(garden)
}
