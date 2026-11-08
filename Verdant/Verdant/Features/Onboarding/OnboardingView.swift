import SwiftUI

// <onboarding>
/// The first-launch experience: swipeable pages, a custom indicator, and buttons
/// to skip, advance and finish. It calls `onFinish` and stores nothing itself.
struct OnboardingView: View {
    let pages = OnboardingPage.all
    let onFinish: () -> Void

    @State private var selection = 0
    private var isLastPage: Bool { selection == pages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip", action: onFinish)
                    .opacity(isLastPage ? 0 : 1)  // keeps the layout stable
                    .disabled(isLastPage)
                    .accessibilityHidden(isLastPage)
            }
            .padding()

            TabView(selection: $selection) {
                ForEach(pages) { page in
                    OnboardingPageView(page: page).tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))  // we draw our own indicator

            PageIndicator(
                count: pages.count, selection: $selection,
                tint: pages[selection].tint
            )
            .padding(.bottom, 24)

            Button {
                if isLastPage {
                    onFinish()
                } else {
                    withAnimation { selection += 1 }
                }
            } label: {
                Text(isLastPage ? "Get started" : "Next")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(pages[selection].tint)
            .padding(.horizontal, 32)
            .padding(.bottom)
            .accessibilityIdentifier("onboarding.primary")
        }
        .background(pages[selection].tint.opacity(0.08).ignoresSafeArea())
        .animation(.easeInOut, value: selection)
    }
}
// </onboarding>

#Preview { OnboardingView {} }
