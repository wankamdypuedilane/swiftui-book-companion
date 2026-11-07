import SwiftUI

// <counter>
struct WateringCounterView: View {
    @State private var glasses = 0  // owned by this view, starts at 0

    var body: some View {
        VStack(spacing: 16) {
            Text("\(glasses)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .contentTransition(.numericText())  // digits roll when they change
            Text("glasses of water today").foregroundStyle(.secondary)
            HStack(spacing: 24) {
                Button("Remove", systemImage: "minus") {
                    withAnimation { glasses -= 1 }
                }
                .disabled(glasses == 0)
                Button("Add", systemImage: "plus") {
                    withAnimation { glasses += 1 }
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .font(.title)
        }
    }
}
// </counter>

#Preview { WateringCounterView() }
