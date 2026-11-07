import SwiftUI

// <indicator>
/// A custom page indicator: the current page is a wide capsule, the others dots.
/// Tapping a dot jumps to its page; VoiceOver users can swipe up and down.
struct PageIndicator: View {
    let count: Int
    @Binding var selection: Int
    var tint: Color = .accentColor

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == selection ? tint : Color.secondary.opacity(0.35))
                    .frame(width: index == selection ? 24 : 8, height: 8)
                    .contentShape(.rect.inset(by: -6))            // a larger tap target
                    .onTapGesture { withAnimation(.snappy) { selection = index } }
            }
        }
        .animation(.snappy, value: selection)
        .accessibilityElement()
        .accessibilityLabel("Page")
        .accessibilityValue("\(selection + 1) of \(count)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: selection = min(selection + 1, count - 1)
            case .decrement: selection = max(selection - 1, 0)
            @unknown default: break
            }
        }
    }
}
// </indicator>

#Preview {
    @Previewable @State var page = 1
    PageIndicator(count: 4, selection: $page)
}
