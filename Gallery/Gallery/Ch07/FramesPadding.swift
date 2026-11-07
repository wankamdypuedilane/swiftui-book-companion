import SwiftUI

// <frames>
struct FramesPaddingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Fixed 200 × 44")
                .frame(width: 200, height: 44)
                .background(.green.opacity(0.2))

            Text("As wide as possible, leading")
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.green.opacity(0.2))

            Text("At least 80 points high")
                .frame(minHeight: 80)
                .background(.green.opacity(0.2))

            Text("Padding on two edges")
                .padding(.horizontal, 32)
                .padding(.vertical, 4)
                .background(.green.opacity(0.2))

            HStack {
                Text("A long label that would be truncated first")
                    .lineLimit(1)
                Text("Important")
                    .lineLimit(1)
                    .layoutPriority(1)        // gets its space before the other text
            }
            .background(.green.opacity(0.2))
        }
        .padding()
    }
}
// </frames>

#Preview { FramesPaddingView() }
