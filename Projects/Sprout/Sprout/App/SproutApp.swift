import SwiftUI

// <app>
@main
struct SproutApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            TodayView(seedlings: Seedling.samples, configuration: .current)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            let change = "\(oldPhase) → \(newPhase)"
            Log.lifecycle.info("Scene phase: \(change, privacy: .public)")
            if newPhase == .background {
                // Save unsaved work here: the system may terminate
                // a background app at any time.
            }
        }
    }
}
// </app>
