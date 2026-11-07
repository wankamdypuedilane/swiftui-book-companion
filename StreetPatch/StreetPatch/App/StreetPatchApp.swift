import StreetPatchKit
import SwiftUI

// <app>
@main
struct StreetPatchApp: App {
    @State private var dependencies = AppDependencies.makeForLaunch()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
                .environment(dependencies.reports)
                .environment(dependencies.session)
                .environment(dependencies.mine)
                .environment(dependencies.network)
                .environment(dependencies.location)
        }
    }
}
// </app>
