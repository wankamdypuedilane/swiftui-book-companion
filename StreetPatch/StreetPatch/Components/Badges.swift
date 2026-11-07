import StreetPatchKit
import SwiftUI

// <badges>
/// The category's symbol in a coloured circle: used on the map and in the list.
struct CategoryIcon: View {
    let category: ReportCategory
    var size: CGFloat = 32

    var body: some View {
        Image(systemName: category.symbolName)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(category.tint, in: .circle)
            .accessibilityHidden(true)  // the row or marker says the category in words
    }
}

/// The status as text in a capsule. The text stays in the primary colour, which keeps
/// its contrast in light and dark mode; the status colour is a dot that repeats it.
struct StatusPill: View {
    let status: ReportStatus

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.tint)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            Text(status.title)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.primary)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(status.tint.opacity(0.12), in: .capsule)
    }
}

extension ReportCategory {
    var tint: Color {
        switch self {
        case .pothole: .brown
        case .streetlight: .orange
        case .graffiti: .purple
        case .litter: .green
        case .drain: .blue
        case .signage: .red
        case .other: .gray
        }
    }
}

extension ReportStatus {
    var tint: Color {
        switch self {
        case .submitted: .secondary
        case .acknowledged: .blue
        case .inProgress: .orange
        case .resolved: .green
        case .rejected: .red
        }
    }
}
// </badges>

extension Double {
    /// "120 m" or "1.4 km", in the user's units.
    var formattedDistance: String {
        Measurement(value: self, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }
}
