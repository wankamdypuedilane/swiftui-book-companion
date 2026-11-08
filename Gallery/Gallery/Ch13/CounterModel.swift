import SwiftUI

// <countermodel>
/// Exercise 13.2: the bounded counter's logic in a view model.
@Observable
final class CounterModel {
    let range: ClosedRange<Int>
    private(set) var value: Int

    init(range: ClosedRange<Int>) {
        self.range = range
        value = range.lowerBound
    }

    var canIncrement: Bool { value < range.upperBound }
    var canDecrement: Bool { value > range.lowerBound }

    func increment() { if canIncrement { value += 1 } }
    func decrement() { if canDecrement { value -= 1 } }
}

struct CounterModelView: View {
    @State private var model: CounterModel

    init(range: ClosedRange<Int>) {
        _model = State(initialValue: CounterModel(range: range))
    }

    var body: some View {
        HStack(spacing: 20) {
            Button("Less", systemImage: "minus.circle") { model.decrement() }
                .disabled(!model.canDecrement)
            Text("\(model.value)").font(.title.monospacedDigit())
            Button("More", systemImage: "plus.circle") { model.increment() }
                .disabled(!model.canIncrement)
        }
        .labelStyle(.iconOnly)
        .font(.title)
    }
}
// </countermodel>
