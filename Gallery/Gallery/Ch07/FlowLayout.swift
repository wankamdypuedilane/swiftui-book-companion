import SwiftUI

// <flow>
/// Exercise 7.4: a layout that places its children in rows, wrapping to a new
/// row when the current one is full (like words in a paragraph).
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let rows = arrange(subviews, maxWidth: proposal.width ?? .infinity)
        let width = rows.map(\.width).max() ?? 0
        let gaps = spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: width, height: rows.map(\.height).reduce(0, +) + gaps)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize,
        subviews: Subviews, cache: inout ()
    ) {
        var y = bounds.minY
        for row in arrange(subviews, maxWidth: bounds.width) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: .init(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    /// Greedy line breaking: each subview goes on the current row if it fits.
    private func arrange(_ subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            // Width of the current row if this subview were added to it.
            let widened =
                current.indices.isEmpty
                ? size.width
                : current.width + spacing + size.width
            if widened > maxWidth, !current.indices.isEmpty {
                rows.append(current)  // full: start a new row
                current = Row()
            }
            current.width =
                current.indices.isEmpty
                ? size.width
                : current.width + spacing + size.width
            current.height = max(current.height, size.height)
            current.indices.append(index)
        }
        if !current.indices.isEmpty { rows.append(current) }
        return rows
    }
}
// </flow>

struct FlowLayoutView: View {
    let tags = [
        "low light", "pet safe", "air purifying", "easy", "trailing",
        "fast growing", "humidity lover", "drought tolerant", "flowering", "edible",
    ]

    var body: some View {
        FlowLayout {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.green.opacity(0.15), in: .capsule)
            }
        }
        .padding()
    }
}

#Preview { FlowLayoutView() }
