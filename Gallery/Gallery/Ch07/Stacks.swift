import SwiftUI

// <stacks>
struct StacksView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // HStack: side by side, vertically centred by default.
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Pothos").font(.title)
                Text("Epipremnum aureum").font(.caption).foregroundStyle(.secondary)
            }

            // Spacer takes all the free space along the stack's axis.
            HStack {
                Label("Living room", systemImage: "sofa")
                Spacer()
                Text("6 plants").foregroundStyle(.secondary)
            }

            Divider()

            // ZStack: on top of each other, centred by default.
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 16).fill(.green.opacity(0.15))
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                Text("NEW")
                    .font(.caption.bold())
                    .padding(6)
                    .background(.orange, in: .capsule)
                    .padding(8)
            }
            .frame(height: 120)
        }
        .padding()
    }
}
// </stacks>

#Preview { StacksView() }
