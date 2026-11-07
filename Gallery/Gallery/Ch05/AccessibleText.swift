import SwiftUI

// <accessible>
struct AccessibleTextView: View {
    // Grows and shrinks with Dynamic Type, like the body text style.
    @ScaledMetric(relativeTo: .body) private var iconSize = 24.0
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(.system(size: iconSize))
                    .foregroundStyle(.blue)
                    .accessibilityHidden(true)  // decorative: VoiceOver skips it
                Text("Water every 7 days")
                    .font(.body)
            }
            Text("3/12")
                .font(.title)
                .accessibilityLabel("3 of 12 plants watered")  // what VoiceOver reads
            Text(typeSize.isAccessibilitySize ? "Accessibility size" : "Standard size")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Never smaller than xSmall, never larger than xxxLarge")
                .dynamicTypeSize(.xSmall ... .xxxLarge)  // limit only when necessary
        }
        .padding()
    }
}
// </accessible>

#Preview { AccessibleTextView() }
#Preview("Largest text") { AccessibleTextView().dynamicTypeSize(.accessibility5) }
