import StreetPatchKit
import SwiftUI

// <reportbutton>
/// "Report a problem", in the navigation bar of the Map and List tabs: reporting is the
/// reason the app exists, so it is one tap away. Signed out, it asks to sign in first.
struct ReportButton: View {
    /// The sheet's content needs an identity: a new one for every presentation.
    private struct Presented: Identifiable {
        let id = UUID()
        let model: ComposerModel
    }

    @Environment(AppDependencies.self) private var dependencies
    @Environment(SessionModel.self) private var session
    @State private var composer: Presented?
    @State private var isSigningIn = false

    var body: some View {
        Button {
            if session.isSignedIn {
                composer = Presented(model: dependencies.makeComposer())
            } else {
                isSigningIn = true
            }
        } label: {
            Label("Report a problem", systemImage: "plus")  // the bar shows the icon
        }
        .accessibilityIdentifier("report.new")
        .sheet(item: $composer) { ComposerView(model: $0.model) }
        .sheet(isPresented: $isSigningIn) { SignInView() }
    }
}
// </reportbutton>
