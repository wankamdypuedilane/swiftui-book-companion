import SwiftUI

// <modifier>
/// A reusable style for section titles, defined once and applied everywhere.
struct SectionTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3.weight(.semibold))
            .foregroundStyle(.primary)
            .textCase(.uppercase)
            .tracking(1.2)
            .accessibilityAddTraits(.isHeader)
    }
}

extension View {
    func sectionTitleStyle() -> some View { modifier(SectionTitleStyle()) }
}

extension Font {
    /// The app's font for numbers that change, such as counters.
    static let counter = Font.system(.largeTitle, design: .rounded).monospacedDigit().bold()
}
// </modifier>

// <usage>
struct TypographyStylesView: View {
    @State private var watered = 7

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Today").sectionTitleStyle()
            Text("\(watered) plants watered").font(.counter)
            Button("Water one more") { watered += 1 }
            Text("This week").sectionTitleStyle()
            Text("Fertilize the citrus tree on Saturday.")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
// </usage>

#Preview { TypographyStylesView() }
