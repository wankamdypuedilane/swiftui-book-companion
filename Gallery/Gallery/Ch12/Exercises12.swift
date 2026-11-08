import SwiftUI

// <wall>
/// Exercise 12.1: square tiles, three columns on iPhone, adaptive on iPad.
struct PhotoWall: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    let symbols = [
        "leaf", "drop", "sun.max", "camera.macro", "tree", "carrot",
        "fish", "bird", "ladybug", "ant", "tortoise", "hare",
    ]

    var columns: [GridItem] {
        sizeClass == .compact
            ? Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)
            : [GridItem(.adaptive(minimum: 120), spacing: 4)]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(symbols, id: \.self) { symbol in
                    Image(systemName: symbol)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(.green.opacity(0.15))
                }
            }
        }
    }
}
// </wall>

// <quantity>
/// Exercise 12.4: a numeric field with a unit, clamped to a range.
struct QuantityField: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String

    var body: some View {
        HStack {
            TextField(title, value: $value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: value) { _, new in
                    value = min(max(new, range.lowerBound), range.upperBound)
                }
            Text(unit).foregroundStyle(.secondary)
        }
    }
}
// </quantity>

struct FormExercisesView: View {
    @State private var water = 250

    var body: some View {
        VStack {
            Form {
                LabeledContent("Water per plant") {
                    QuantityField(title: "Water", value: $water, range: 50...2_000, unit: "ml")
                }
                Text("Stored value: \(water) ml")
            }
            .frame(height: 160)
            PhotoWall()
        }
    }
}

#Preview { FormExercisesView() }
