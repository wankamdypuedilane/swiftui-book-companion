import SwiftUI

// <leaf>
/// A leaf drawn with two quadratic curves between its base and its tip.
struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let base = CGPoint(x: rect.midX, y: rect.maxY)
        let tip = CGPoint(x: rect.midX, y: rect.minY)
        path.move(to: base)
        let bulge = rect.width * 0.2
        path.addQuadCurve(to: tip, control: CGPoint(x: rect.minX - bulge, y: rect.midY))
        path.addQuadCurve(to: base, control: CGPoint(x: rect.maxX + bulge, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
// </leaf>

// <ring>
/// A progress ring: a background circle and a trimmed circle on top.
struct ProgressRing: View {
    let progress: Double  // 0...1
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle().stroke(.green.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))  // start at 12 o'clock
            Text(progress, format: .percent.precision(.fractionLength(0)))
                .font(.title2.bold())
        }
        .padding(lineWidth / 2)
    }
}
// </ring>

struct CustomShapesView: View {
    @State private var progress = 0.65

    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 24) {
                LeafShape().fill(.green).frame(width: 60, height: 100)
                LeafShape().stroke(.green, lineWidth: 3).frame(width: 40, height: 100)
                LeafShape().fill(.mint)
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(45))
            }
            ProgressRing(progress: progress).frame(width: 140, height: 140)
            Slider(value: $progress, in: 0...1) { Text("Progress") }
        }
        .padding()
    }
}

#Preview { CustomShapesView() }
