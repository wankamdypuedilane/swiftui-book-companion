import SwiftUI

// <shapes>
struct ShapesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Rectangle().fill(.green)
                    RoundedRectangle(cornerRadius: 12).fill(.mint)
                    Circle().fill(.teal)
                    Capsule().fill(.cyan)
                    Ellipse().fill(.blue)
                }
                .frame(height: 50)

                HStack(spacing: 16) {
                    Circle().stroke(.green, lineWidth: 8)  // centred on the edge
                    Circle().strokeBorder(.green, lineWidth: 8)  // entirely inside
                    Circle().stroke(.green, style: StrokeStyle(lineWidth: 4, dash: [6, 4]))
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.green.opacity(0.2))
                        .stroke(.green, lineWidth: 2)  // fill, then stroke
                }
                .frame(height: 70)

                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        .linearGradient(
                            colors: [.green, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)
                    )
                    .frame(height: 100)
                    .overlay {
                        Text("Shapes fill the space they are offered").bold()
                    }
            }
            .padding()
        }
    }
}
// </shapes>

#Preview { ShapesView() }
