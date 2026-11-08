import SwiftUI

// <defaults>
/// Preferences: small values in UserDefaults, through @AppStorage.
struct PreferencesView: View {
    enum Units: String, CaseIterable, Identifiable {
        case metric, imperial
        var id: Self { self }
    }

    @AppStorage("units") private var units = Units.metric  // RawRepresentable works
    @AppStorage("showsLatinNames") private var showsLatinNames = true
    @AppStorage("lastOpened") private var lastOpened = Date.now.timeIntervalSince1970

    var body: some View {
        Form {
            Picker("Units", selection: $units) {
                ForEach(Units.allCases) { Text($0.rawValue.capitalized).tag($0) }
            }
            Toggle("Show Latin names", isOn: $showsLatinNames)
            LabeledContent("Last opened") {
                Text(Date(timeIntervalSince1970: lastOpened), style: .relative)
            }
        }
        .onDisappear { lastOpened = Date.now.timeIntervalSince1970 }
    }
}
// </defaults>

#Preview { PreferencesView() }
