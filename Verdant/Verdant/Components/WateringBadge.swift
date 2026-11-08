import SwiftUI
import VerdantKit

// <badge>
/// A compact label for a watering status: "In 3 days", "Today", "2 days late".
struct WateringBadge: View {
    let status: WateringStatus

    var body: some View {
        // The colour goes to the icon and the background; the text stays in the primary
        // colour, because orange text on white fails the contrast check.
        HStack(spacing: 4) {
            Image(systemName: status.needsWater ? "drop.fill" : "drop")
                .foregroundStyle(color)
                .accessibilityHidden(true)
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15), in: .capsule)
    }

    private var text: String {
        switch status {
        case .overdue(let days): days == 1 ? "1 day late" : "\(days) days late"
        case .dueToday: "Today"
        case .upcoming(let days): days == 1 ? "Tomorrow" : "In \(days) days"
        }
    }

    private var color: Color {
        switch status {
        case .overdue: .red
        case .dueToday: .orange
        case .upcoming: .secondary
        }
    }
}
// </badge>

#Preview {
    VStack {
        WateringBadge(status: .overdue(days: 2))
        WateringBadge(status: .dueToday)
        WateringBadge(status: .upcoming(days: 5))
    }
}
