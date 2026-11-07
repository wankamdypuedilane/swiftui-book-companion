import SwiftUI

// <composition>
/// A dashboard composed of three small, reusable views.
struct GardenDashboard: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                DashboardHeader(name: "Amina", thirsty: 3)
                HStack(spacing: 16) {
                    StatTile(value: "12", label: "Plants", systemImage: "leaf.fill")
                    StatTile(value: "3", label: "Thirsty", systemImage: "drop.fill")
                    StatTile(value: "5", label: "Rooms", systemImage: "house.fill")
                }
                // ProgressRing is defined in CustomShapes.swift
                ProgressRing(progress: 0.75).frame(height: 140)
            }
            .padding()
        }
    }
}

struct DashboardHeader: View {
    let name: String
    let thirsty: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hello, \(name)").font(.largeTitle.bold())
            Text(thirsty == 0 ? "Everything is watered."
                              : "\(thirsty) plants are thirsty today.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StatTile: View {
    let value: String
    let label: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage).font(.title2).foregroundStyle(.green)
            Text(value).font(.title.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}
// </composition>

#Preview { GardenDashboard() }
