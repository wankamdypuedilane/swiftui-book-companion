import SwiftUI

// <style>
/// A pill-shaped button style that shrinks slightly while pressed.
struct PillButtonStyle: ButtonStyle {
    var color: Color = .green

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1), in: .capsule)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    /// Lets callers write `.buttonStyle(.pill)`.
    static var pill: PillButtonStyle { PillButtonStyle() }
}
// </style>

struct CustomButtonStyleView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Mistings: \(count)")
            Button("Mist the fern") { count += 1 }.buttonStyle(.pill)
            Button("Mist in orange") { count += 1 }
                .buttonStyle(PillButtonStyle(color: .orange))
        }
    }
}

#Preview { CustomButtonStyleView() }
