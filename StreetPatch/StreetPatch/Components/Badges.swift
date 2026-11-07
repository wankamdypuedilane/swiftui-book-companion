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

/// The status as text in a capsule. Colour repeats the word, it never replaces it.
struct StatusPill: View {
    let status: ReportStatus

    var body: some View {
        Text(status.title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(status.tint)
            .background(status.tint.opacity(0.15), in: .capsule)
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
