import SwiftUI
import VerdantKit

// <card>
/// A cell of the catalogue grid. The fixed number of lines keeps cells aligned.
struct SpeciesCard: View {
    let species: Species

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: species.symbolName)
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(.tint.opacity(0.1), in: .rect(cornerRadius: 12))
                .accessibilityHidden(true)
            Text(species.commonName)
                .font(.headline)
                .lineLimit(1)
            Text(species.scientificName)
                .font(.caption)
                .italic()
                .foregroundStyle(.secondary)
                .lineLimit(1)
            HStack(spacing: 6) {
                Label("\(species.wateringDays) d", systemImage: "drop")
                Label(species.light.rawValue.capitalized, systemImage: species.light.symbolName)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .labelStyle(.titleAndIcon)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}
// </card>

#Preview {
    SpeciesCard(species: SampleData.species[0]).frame(width: 170).padding()
}
