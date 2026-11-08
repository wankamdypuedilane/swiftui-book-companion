import SwiftUI

// <privacy>
/// Exercise 23.2: blurs a view when the scene is not active, so that the app
/// switcher's snapshot does not show its content.
struct PrivacySensitiveWhenInactive: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .blur(radius: scenePhase == .active ? 0 : 12)
            .animation(.default, value: scenePhase)
    }
}

extension View {
    func privacySensitiveWhenInactive() -> some View {
        modifier(PrivacySensitiveWhenInactive())
    }
}
// </privacy>
