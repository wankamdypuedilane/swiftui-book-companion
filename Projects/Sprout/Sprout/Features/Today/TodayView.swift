import SwiftUI

struct TodayView: View {
    let seedlings: [Seedling]
    let configuration: AppConfiguration

    var body: some View {
        NavigationStack {
            List {
                Section("Tray") {
                    ForEach(Array(Seedling.trayRows(seedlings, columns: 3).enumerated()), id: \.offset) { index, row in
                        LabeledContent("Row \(index + 1)", value: row.map(\.variety).joined(separator: ", "))
                    }
                }
                Section("Seedlings") {
                    ForEach(seedlings) { seedling in
                        HStack {
                            Label(seedling.variety, systemImage: "leaf")
                            Spacer()
                            Text("\(seedling.ageInDays(on: .now)) days")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Build") {
                    LabeledContent("Environment", value: configuration.environmentName)
                    LabeledContent("API", value: configuration.apiBaseURL.absoluteString)
                }
            }
            .navigationTitle("Sprout")
        }
        .tint(Color(.leafGreen))            // symbol generated from the asset catalog
    }
}

#Preview {
    TodayView(seedlings: Seedling.samples,
              configuration: AppConfiguration(apiBaseURL: URL(string: "http://localhost:8080")!,
                                              environmentName: "Preview"))
}
