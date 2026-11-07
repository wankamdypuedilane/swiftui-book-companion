import SwiftUI

// <responsive>
struct ResponsiveLayoutView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 1. ViewThatFits picks the first child that fits the width.
                ViewThatFits(in: .horizontal) {
                    HStack { actions }
                    VStack { actions }
                }

                // 2. The size class: compact (iPhone portrait) or regular width.
                Text(sizeClass == .regular ? "Regular width" : "Compact width")
                    .font(.headline)

                // 3. A size relative to the scroll view's visible area.
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(1...6, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.green.gradient)
                                .overlay { Text("Card \(index)").foregroundStyle(.white) }
                                .containerRelativeFrame(
                                    .horizontal, count: 5, span: 4,
                                    spacing: 12
                                )
                                .frame(height: 120)
                        }
                    }
                }
                .contentMargins(.horizontal, 16, for: .scrollContent)

                // 4. GeometryReader when a view needs the exact size it is given.
                GeometryReader { proxy in
                    Text("This area is \(Int(proxy.size.width)) points wide")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.green.opacity(0.15))
                }
                .frame(height: 60)
            }
            .padding(.vertical)
        }
    }

    @ViewBuilder private var actions: some View {
        Button("Water all") {}
        Button("Add a plant") {}
        Button("Share the garden") {}
    }
}
// </responsive>

#Preview { ResponsiveLayoutView() }
