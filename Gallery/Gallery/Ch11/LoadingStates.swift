import SwiftUI

// <states>
/// The four states of a screen that loads data: loading, failed, empty, loaded.
struct LoadingStatesView: View {
    enum Phase: Hashable { case loading, failed, empty, loaded }
    @State private var phase = Phase.loading

    var body: some View {
        VStack {
            Picker("State", selection: $phase) {
                Text("Loading").tag(Phase.loading)
                Text("Failed").tag(Phase.failed)
                Text("Empty").tag(Phase.empty)
                Text("Loaded").tag(Phase.loaded)
            }
            .pickerStyle(.segmented)
            .padding()

            Group {
                switch phase {
                case .loading:
                    ProgressView("Loading swaps…")
                case .failed:
                    ContentUnavailableView {
                        Label("No connection", systemImage: "wifi.slash")
                    } description: {
                        Text("The swaps could not be loaded.")
                    } actions: {
                        Button("Try again") { phase = .loading }.buttonStyle(.bordered)
                    }
                case .empty:
                    ContentUnavailableView(
                        "No swaps nearby", systemImage: "leaf",
                        description: Text("Offer the first cutting."))
                case .loaded:
                    List(1...20, id: \.self) { Text("Swap #\($0)") }
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}
// </states>

#Preview { LoadingStatesView() }
