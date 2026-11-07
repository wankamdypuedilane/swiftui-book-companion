import SwiftUI

// <rating>
/// Exercise 8.2: a reusable rating control bound to its owner's value.
struct RatingControl: View {
    @Binding var rating: Int
    var maximum = 5

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maximum, id: \.self) { value in
                Button {
                    rating = (rating == value) ? 0 : value  // tap again to clear
                } label: {
                    Image(systemName: value <= rating ? "star.fill" : "star")
                        .foregroundStyle(value <= rating ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .font(.title2)
        .accessibilityElement()
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) out of \(maximum)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: rating = min(rating + 1, maximum)
            case .decrement: rating = max(rating - 1, 0)
            @unknown default: break
            }
        }
    }
}
// </rating>

// <checkbox>
/// Exercise 8.4: a toggle style that draws a checkbox.
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                    .font(.title3)
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkbox: CheckboxToggleStyle { CheckboxToggleStyle() }
}
// </checkbox>

// <limited>
/// Exercise 8.1: a counter with a lower and an upper limit.
struct LimitedCounter: View {
    let range: ClosedRange<Int>
    @State private var value: Int

    init(range: ClosedRange<Int>) {
        self.range = range
        _value = State(initialValue: range.lowerBound)
    }

    var body: some View {
        HStack(spacing: 20) {
            Button("Less", systemImage: "minus.circle") { value -= 1 }
                .disabled(value == range.lowerBound)
            Text("\(value)").font(.title.monospacedDigit()).frame(minWidth: 44)
            Button("More", systemImage: "plus.circle") { value += 1 }
                .disabled(value == range.upperBound)
        }
        .labelStyle(.iconOnly)
        .font(.title)
    }
}
// </limited>

struct StateExercisesView: View {
    @State private var rating = 3
    @State private var tasks = [false, true, false]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            LimitedCounter(range: 1...5)
            RatingControl(rating: $rating)
            Text("Rating: \(rating)")
            Toggle("Water the ferns", isOn: $tasks[0]).toggleStyle(.checkbox)
            Toggle("Rotate the cactus", isOn: $tasks[1]).toggleStyle(.checkbox)
            Toggle("Feed the citrus", isOn: $tasks[2]).toggleStyle(.checkbox)
        }
        .padding()
    }
}

#Preview { StateExercisesView() }
