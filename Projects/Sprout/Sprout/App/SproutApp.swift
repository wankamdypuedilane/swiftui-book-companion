import SwiftUI

@main
struct SproutApp: App {
    var body: some Scene {
        WindowGroup {
            TodayView(seedlings: Seedling.samples, configuration: .current)
        }
    }
}
