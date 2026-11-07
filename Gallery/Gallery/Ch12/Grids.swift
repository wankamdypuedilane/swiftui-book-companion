import SwiftUI

// <lazygrid>
struct LazyGridsView: View {
    let symbols = [
        "leaf", "drop", "sun.max", "camera.macro", "tree", "carrot",
        "fish", "bird", "ladybug", "ant", "tortoise", "hare",
    ]

    // Three ways to define columns.
    let fixed = [GridItem(.fixed(80)), GridItem(.fixed(80)), GridItem(.fixed(80))]
    let flexible = [GridItem(.flexible()), GridItem(.flexible(minimum: 120))]
    let adaptive = [GridItem(.adaptive(minimum: 70), spacing: 8)]  // as many as fit

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Adaptive").font(.headline)
                LazyVGrid(columns: adaptive, spacing: 8) {
                    ForEach(symbols, id: \.self) { tile($0) }
                }
                Text("Fixed").font(.headline)
                LazyVGrid(columns: fixed) {
                    ForEach(symbols.prefix(6), id: \.self) { tile($0) }
                }
                Text("Flexible").font(.headline)
                LazyVGrid(columns: flexible) {
                    ForEach(symbols.prefix(4), id: \.self) { tile($0) }
                }
                Text("Horizontal").font(.headline)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [GridItem(.fixed(70)), GridItem(.fixed(70))], spacing: 8) {
                        ForEach(symbols, id: \.self) { tile($0).frame(width: 70) }
                    }
                }
            }
            .padding()
        }
    }

    private func tile(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.title)
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(.green.opacity(0.15), in: .rect(cornerRadius: 12))
    }
}
// </lazygrid>

// <grid>
/// Grid (not lazy) aligns cells in rows and columns, like a table.
struct GridLayoutView: View {
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
            GridRow {
                Text("Plant").bold()
                Text("Water").bold()
                Text("Light").bold()
            }
            Divider().gridCellUnsizedAxes(.horizontal)
            GridRow {
                Text("Fern")
                Text("3 days")
                Image(systemName: "sun.haze")
            }
            GridRow {
                Text("Snake plant")
                Text("21 days")
                Image(systemName: "sun.min")
            }
            GridRow {
                Text("A note spanning every column").gridCellColumns(3).foregroundStyle(
                    .secondary)
            }
        }
        .padding()
    }
}
// </grid>

#Preview("Lazy grids") { LazyGridsView() }
#Preview("Grid") { GridLayoutView() }
