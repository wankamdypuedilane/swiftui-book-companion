import StreetPatchKit
import SwiftUI

// <root>
/// Three tabs. Back online, the outbox sends what waited.
struct RootView: View {
    @Environment(SessionModel.self) private var session
    @Environment(NetworkMonitor.self) private var network
    @Environment(MyReportsModel.self) private var mine

    var body: some View {
        TabView {
            Tab("Map", systemImage: "map") { ReportsMapView() }
            Tab("List", systemImage: "list.bullet") { ReportListView() }
            Tab("Mine", systemImage: "person.crop.circle") { MyReportsView() }
        }
        .task {
            network.start()
            await session.restore()
        }
        .onChange(of: network.isConnected) { _, connected in
            if connected { Task { await mine.refresh() } }
        }
    }
}
// </root>
