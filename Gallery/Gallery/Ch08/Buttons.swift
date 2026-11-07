import SwiftUI

// <buttons>
struct ButtonsView: View {
    @State private var log = "Tap a button"

    var body: some View {
        VStack(spacing: 16) {
            Text(log).font(.headline)

            Button("Water") { log = "Watered" }                         // a text title

            Button {                                                    // any view as label
                log = "Added"
            } label: {
                Label("Add a plant", systemImage: "plus.circle.fill")
            }

            Button("Delete", role: .destructive) { log = "Deleted" }   // red, announced

            HStack {
                Button("Bordered") { log = "Bordered" }.buttonStyle(.bordered)
                Button("Prominent") { log = "Prominent" }.buttonStyle(.borderedProminent)
                Button("Plain") { log = "Plain" }.buttonStyle(.plain)
            }

            Button("Large and round") { log = "Large" }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .buttonBorderShape(.capsule)
                .tint(.green)

            if #available(iOS 26, *) {
                Button("Glass (iOS 26)") { log = "Glass" }.buttonStyle(.glass)
            }

            Button("Disabled") {}.disabled(true)
        }
        .padding()
    }
}
// </buttons>

#Preview { ButtonsView() }
