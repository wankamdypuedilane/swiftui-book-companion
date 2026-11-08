import SwiftUI

// <pageview>
/// One page of the onboarding: a large symbol, a title and a message.
struct OnboardingPageView: View {
    let page: OnboardingPage
    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize = 120.0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: page.symbolName)
                .font(.system(size: symbolSize))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(page.tint)
                .accessibilityHidden(true)
            Text(page.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(page.message)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
// </pageview>

#Preview { OnboardingPageView(page: OnboardingPage.all[1]) }
