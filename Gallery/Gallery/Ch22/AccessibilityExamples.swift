import SwiftUI

// <voiceover>
/// A card made accessible: one element, a clear label, a value, custom actions.
struct AccessibleCard: View {
    let name: String
    let daysUntilWatering: Int
    @State private var isFavorite = false
    @State private var watered = 0

    var body: some View {
        HStack {
            Image(systemName: "leaf.fill").foregroundStyle(.green)
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                Text("Water in \(daysUntilWatering) days").font(.subheadline)
            }
            Spacer()
            Button("Favourite", systemImage: isFavorite ? "star.fill" : "star") {
                isFavorite.toggle()
            }
            .labelStyle(.iconOnly)
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 12))
        // VoiceOver: one element instead of four, read in a natural order.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(name)
        .accessibilityValue("Water in \(daysUntilWatering) days, watered \(watered) times")
        .accessibilityAddTraits(isFavorite ? [.isSelected] : [])
        .accessibilityHint("Shows the care history")
        // Actions available from the rotor, without hunting for small buttons.
        .accessibilityAction(named: isFavorite ? "Remove from favourites" : "Add to favourites")
        {
            isFavorite.toggle()
        }
        .accessibilityAction(named: "Water now") { watered += 1 }
    }
}
// </voiceover>

// <adaptive>
/// Adapts to Dynamic Type, Reduce Motion and Differentiate Without Color.
struct AdaptiveStatus: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var withoutColor
    @State private var isThirsty = true

    var body: some View {
        let layout =
            typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout())
        layout {
            Circle()
                .fill(isThirsty ? .red : .green)
                .frame(width: 16, height: 16)
                .overlay {
                    if withoutColor {  // a shape, not only a colour
                        Image(systemName: isThirsty ? "exclamationmark" : "checkmark")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                    }
                }
            Text(isThirsty ? "Needs water" : "Watered")
            Button("Toggle") {
                withAnimation(reduceMotion ? nil : .spring) { isThirsty.toggle() }
            }
        }
    }
}
// </adaptive>

struct AccessibilityExamplesView: View {
    var body: some View {
        VStack(spacing: 24) {
            AccessibleCard(name: "Monty", daysUntilWatering: 2)
            AdaptiveStatus()
        }
        .padding()
    }
}

#Preview { AccessibilityExamplesView() }
#Preview("Accessibility size") {
    AccessibilityExamplesView().dynamicTypeSize(.accessibility3)
}
