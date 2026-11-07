import SwiftUI
import VerdantKit

// <row>
/// A row of the garden list.
struct PlantRow: View {
    let plant: Plant
    let status: WateringStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: plant.room.symbolName)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 40, height: 40)
                .background(.tint.opacity(0.12), in: .circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(plant.nickname).font(.headline)
                    if plant.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                            .accessibilityLabel("Favourite")
                    }
                }
                Text(plant.speciesName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            WateringBadge(status: status)
        }
        .accessibilityElement(children: .combine)
    }
}
// </row>

#Preview {
    List {
        PlantRow(plant: SampleData.garden()[0], status: .dueToday)
        PlantRow(plant: SampleData.garden()[1], status: .upcoming(days: 4))
    }
}
