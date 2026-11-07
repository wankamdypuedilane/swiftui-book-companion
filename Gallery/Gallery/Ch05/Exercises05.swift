import SwiftUI

// <pricetag>
/// Exercise 5.1: a price tag with an optional former price.
struct PriceTag: View {
    let name: String
    let price: Decimal
    var formerPrice: Decimal?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)
                .lineLimit(1)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(price, format: .currency(code: "EUR"))
                    .font(.title2.bold())
                    .foregroundStyle(formerPrice == nil ? Color.primary : Color.red)
                if let formerPrice {
                    Text(formerPrice, format: .currency(code: "EUR"))
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(
                            Text("was \(formerPrice, format: .currency(code: "EUR"))"))
                }
            }
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 12))
    }
}
// </pricetag>

struct PriceTagExercise: View {
    var body: some View {
        VStack(spacing: 16) {
            PriceTag(name: "Terracotta pot, 14 cm", price: 7.10)
            PriceTag(name: "Monstera deliciosa", price: 19.90, formerPrice: 24.90)
        }
        .padding()
    }
}

// <adaptive>
/// Exercise 5.4: a header that stacks vertically at accessibility text sizes.
struct AdaptiveHeader: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    let title: String
    let subtitle: String

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 8))
        layout {
            Text(title).font(.title2.bold())
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
// </adaptive>

struct AdaptiveHeaderExercise: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            AdaptiveHeader(title: "Living room", subtitle: "6 plants")
            AdaptiveHeader(title: "Balcony", subtitle: "3 plants")
                .dynamicTypeSize(.accessibility3)
        }
        .padding()
    }
}

// <carecard>
/// Exercise 5.3: a care-instructions card built only from text styles.
struct CareCard: View {
    let name: String
    let botanicalName: String
    let instructions: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name).font(.title2.bold())
            Text(botanicalName)
                .font(.subheadline)
                .italic()
                .foregroundStyle(.secondary)
            Text(instructions)
                .font(.body)
                .lineLimit(4, reservesSpace: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}
// </carecard>

struct CareCardExercise: View {
    let text = "Keep the soil lightly moist from spring to autumn and let it dry a little "
        + "more in winter. Mist the leaves in dry rooms and keep away from radiators."

    var body: some View {
        ScrollView {
            CareCard(name: "Calathea", botanicalName: "Goeppertia orbifolia",
                     instructions: text)
                .padding()
        }
    }
}

#Preview("Largest text") {
    CareCardExercise().dynamicTypeSize(.accessibility5)
}
