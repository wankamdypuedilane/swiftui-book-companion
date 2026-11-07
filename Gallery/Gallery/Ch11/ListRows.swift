import SwiftUI

// <rows>
struct CustomRowsView: View {
    struct Swap: Identifiable {
        let id: Int
        let plant: String
        let offeredBy: String
        let distanceKm: Double
        var isReserved = false
    }

    @State private var swaps = [
        Swap(id: 1, plant: "Pothos cutting", offeredBy: "Inès", distanceKm: 0.8),
        Swap(id: 2, plant: "Spider plant baby", offeredBy: "Malo", distanceKm: 2.4),
        Swap(id: 3, plant: "Aloe pup", offeredBy: "Yann", distanceKm: 5.1),
    ]
    @State private var selection: Set<Int> = []

    var body: some View {
        List(selection: $selection) {
            ForEach($swaps) { $swap in
                HStack {
                    VStack(alignment: .leading) {
                        Text(swap.plant).font(.headline)
                        Text("from \(swap.offeredBy)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(
                        Measurement(value: swap.distanceKm, unit: UnitLength.kilometers),
                        format: .measurement(width: .abbreviated)
                    )
                    .monospacedDigit()
                }
                .listRowBackground(swap.isReserved ? Color.green.opacity(0.12) : nil)
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button(
                        swap.isReserved ? "Release" : "Reserve",
                        systemImage: swap.isReserved ? "xmark" : "checkmark"
                    ) {
                        swap.isReserved.toggle()
                    }
                    .tint(.green)
                }
                .swipeActions(edge: .trailing) {
                    Button("Hide", systemImage: "eye.slash", role: .destructive) {
                        swaps.removeAll { $0.id == swap.id }
                    }
                }
                .contextMenu {
                    Button("Message \(swap.offeredBy)", systemImage: "message") {}
                    Button("Share", systemImage: "square.and.arrow.up") {}
                }
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, .constant(.inactive))
    }
}
// </rows>

#Preview { CustomRowsView() }
