import SwiftUI

// <symbols>
struct SymbolsView: View {
    @State private var moisture = 0.6
    @State private var waterings = 0

    var body: some View {
        List {
            Section("Size follows the font") {
                HStack(spacing: 24) {
                    Image(systemName: "leaf.fill").font(.caption)
                    Image(systemName: "leaf.fill").font(.title)
                    Image(systemName: "leaf.fill").imageScale(.large)
                    Label("Water", systemImage: "drop.fill")
                }
            }
            Section("Rendering modes") {
                HStack(spacing: 24) {
                    Image(systemName: "cloud.sun.rain.fill")  // monochrome
                    Image(systemName: "cloud.sun.rain.fill")
                        .symbolRenderingMode(.hierarchical)
                    Image(systemName: "cloud.sun.rain.fill")
                        .symbolRenderingMode(.multicolor)
                    Image(systemName: "cloud.sun.rain.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.gray, .yellow, .blue)
                }
                .font(.largeTitle)
                .foregroundStyle(.green)
            }
            Section("Variants and variable values") {
                HStack(spacing: 24) {
                    Image(systemName: "heart")
                    Image(systemName: "heart").symbolVariant(.fill)
                    Image(systemName: "heart").symbolVariant(.circle.fill)
                    Image(systemName: "humidity.fill", variableValue: moisture)
                }
                .font(.title)
                Slider(value: $moisture, in: 0...1) { Text("Moisture") }
            }
            Section("Symbol effects") {
                Button {
                    waterings += 1
                } label: {
                    Label("Water (\(waterings))", systemImage: "drop.fill")
                        .symbolEffect(.bounce, value: waterings)
                }
            }
        }
    }
}
// </symbols>

#Preview { SymbolsView() }
