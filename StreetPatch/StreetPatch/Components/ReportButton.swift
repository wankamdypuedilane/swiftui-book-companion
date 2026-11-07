import StreetPatchKit
import SwiftUI

// <reportbutton>
/// "Report a problem", shown at the bottom of the Map and List tabs: reporting is the
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
            Label("Report a problem", systemImage: "plus.circle.fill")
                .font(.headline)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .shadow(radius: 4, y: 2)
        .padding(.bottom, 8)
        .accessibilityIdentifier("report.new")
        .sheet(item: $composer) { ComposerView(model: $0.model) }
        .sheet(isPresented: $isSigningIn) { SignInView() }
    }
}
// </reportbutton>
