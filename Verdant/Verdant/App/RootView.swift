import SwiftUI
import VerdantKit

// <root>
/// Shows the onboarding until it has been completed, then the main interface.
struct RootView: View {
    @AppStorage(SettingsKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Environment(Router.self) private var router

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView {
                    withAnimation(.easeInOut) { hasCompletedOnboarding = true }
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onOpenURL { url in router.handle(url) }
    }
}
// </root>

/// The keys of the values Verdant stores in UserDefaults, in one place.
enum SettingsKey {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let reminderHour = "reminderHour"
    static let remindersOn = "remindersOn"
}
