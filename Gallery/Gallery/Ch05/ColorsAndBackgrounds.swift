import SwiftUI

// <colors>
struct TextColorsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Primary").foregroundStyle(.primary)
            Text("Secondary").foregroundStyle(.secondary)
            Text("Tinted").foregroundStyle(.tint)
            Text("Green").foregroundStyle(.green)
            Text("Gradient title")
                .font(.largeTitle.bold())
                .foregroundStyle(
                    .linearGradient(
                        colors: [.green, .teal],
                        startPoint: .leading, endPoint: .trailing))
            Text("On a capsule")
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(.white)
                .background(.green, in: .capsule)
            Text("On a material")
                .padding()
                .background(.thinMaterial, in: .rect(cornerRadius: 12))
            // A Text can be interpolated into another Text to style part of a sentence.
            Text("Water \(Text("today").bold().foregroundStyle(.red)), not tomorrow.")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.green.opacity(0.08))
    }
}
// </colors>

#Preview { TextColorsView() }
