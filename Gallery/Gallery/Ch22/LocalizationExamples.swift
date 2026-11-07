import SwiftUI

// <localization>
/// Text that can be translated: literals are keys of the String Catalog.
struct LocalizationExamplesView: View {
    @State private var count = 1
    let lastWatered = Date.now.addingTimeInterval(-2 * 86_400)
    let price = Decimal(string: "12.5") ?? 0

    var body: some View {
        Form {
            Section("Translated text") {
                Text("Welcome to your garden")
                // A plural rule from the String Catalog: "1 plant", "2 plants",
                // and in French "1 plante", "2 plantes".
                Text("\(count) plants need water")
                Stepper("Plants: \(count)", value: $count, in: 0...20)
            }
            Section("Formatted for the locale") {
                Text(lastWatered, format: .dateTime.weekday(.wide).day().month(.wide))
                Text(price, format: .currency(code: "EUR"))
                Text(1_234.5, format: .number)
                Text(
                    Measurement(value: 2.5, unit: UnitLength.kilometers),
                    format: .measurement(width: .wide))
            }
            Section("In code") {
                // String(localized:) looks up the same catalog outside of Text.
                Text(String(localized: "Water every day", comment: "A watering interval"))
            }
        }
    }
}
// </localization>

// <previews>
#Preview("English") { LocalizationExamplesView() }
#Preview("French") {
    LocalizationExamplesView().environment(\.locale, Locale(identifier: "fr_FR"))
}
#Preview("Right to left") {
    LocalizationExamplesView().environment(\.layoutDirection, .rightToLeft)
}
// </previews>
