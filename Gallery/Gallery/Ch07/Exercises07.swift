import SwiftUI

// <badge>
/// Exercise 7.2: a bell with a badge that grows into a capsule.
struct BellWithBadge: View {
    let count: Int

    var body: some View {
        Image(systemName: "bell.fill")
            .font(.largeTitle)
            .overlay(alignment: .topTrailing) {
                Text(count, format: .number)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .frame(minWidth: 18, minHeight: 18)
                    .background(.red, in: .capsule)
                    .offset(x: 8, y: -6)
            }
            .accessibilityElement()
            .accessibilityLabel("\(count) notifications")
    }
}
// </badge>

// <timeline>
/// Exercise 7.3: the next seven days, with the watering days filled.
struct WateringTimeline: View {
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    let wateringDays: Set<Int>

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { index in
                VStack(spacing: 6) {
                    let isWateringDay = wateringDays.contains(index)
                    Circle()
                        .fill(isWateringDay ? Color.blue : Color(.systemBackground))
                        .strokeBorder(.blue, lineWidth: 2)
                        .frame(width: 18, height: 18)
                    Text(days[index]).font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(alignment: .top) {
            Rectangle()
                .fill(.blue.opacity(0.3))
                .frame(height: 2)
                .padding(.top, 8)
        }
    }
}
// </timeline>

struct LayoutExercisesView: View {
    var body: some View {
        VStack(spacing: 40) {
            HStack(spacing: 40) {
                BellWithBadge(count: 3)
                BellWithBadge(count: 12)
            }
            WateringTimeline(wateringDays: [0, 3, 5])
        }
        .padding()
    }
}

#Preview { LayoutExercisesView() }
