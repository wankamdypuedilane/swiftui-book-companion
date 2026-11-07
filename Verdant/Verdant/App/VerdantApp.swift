import SwiftUI

// <app>
@main
struct VerdantApp: App {
    @State private var dependencies = AppDependencies.makeForLaunch()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies.garden)
                .environment(dependencies.catalog)
                .environment(dependencies.places)
                .environment(dependencies.account)
                .environment(dependencies.reminders)
                .environment(dependencies.network)
                .environment(dependencies.router)
                .task { await dependencies.start() }
        }
    }
}
// </app>
