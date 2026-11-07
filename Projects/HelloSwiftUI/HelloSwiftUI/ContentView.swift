import SwiftUI

// <template>
struct ContentView: View {
    @State private var visits = 0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)
            Text("Hello, SwiftUI!")
                .font(.largeTitle.bold())
            Text("You tapped \(visits) time\(visits == 1 ? "" : "s").")
                .foregroundStyle(.secondary)
            Button("Tap me") {
                visits += 1
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
// </template>
