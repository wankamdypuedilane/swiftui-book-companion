import SwiftUI
import VerdantKit

// <speciesdetail>
struct SpeciesDetailView: View {
    let species: Species
    @Environment(Garden.self) private var garden
    @State private var isAdding = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(species.scientificName).font(.title3).italic()
                    Text(species.summary)
                }
                .padding(.vertical, 4)
            }
            Section("Care") {
                LabeledContent("Light") { Label(species.light.title, systemImage: species.light.symbolName) }
                LabeledContent("Water every", value: "\(species.wateringDays) days")
                LabeledContent("Difficulty", value: species.difficulty.title)
                LabeledContent("Family", value: species.family)
                LabeledContent("Safe for pets") {
                    Label(species.petSafe ? "Yes" : "No",
                          systemImage: species.petSafe ? "checkmark.circle" : "exclamationmark.triangle")
                        .foregroundStyle(species.petSafe ? .green : .orange)
                }
            }
            Section {
                Button("Add to my garden", systemImage: "plus.circle.fill") { isAdding = true }
            }
        }
        .navigationTitle(species.commonName)
        .sheet(isPresented: $isAdding) {
            PlantEditorView(model: PlantEditorModel(garden: garden, species: species))
        }
    }
}
// </speciesdetail>
