import SwiftUI

// <mistake>
/// A classic mistake: copying a parent's value into the child's own @State.
struct StaleLabel: View {
    @State private var value: Int  // initialized once, then owned here
    init(value: Int) { _value = State(initialValue: value) }
    var body: some View { Text("Copied into @State: \(value)") }
}

struct FreshLabel: View {
    let value: Int  // re-read on every update of the parent
    var body: some View { Text("Plain property: \(value)") }
}

struct StateMistakesView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Button("Increment (\(count))") { count += 1 }.buttonStyle(.borderedProminent)
            StaleLabel(value: count)  // stays at 0: its @State ignores new values
            FreshLabel(value: count)  // follows the parent
        }
    }
}
// </mistake>

#Preview { StateMistakesView() }
