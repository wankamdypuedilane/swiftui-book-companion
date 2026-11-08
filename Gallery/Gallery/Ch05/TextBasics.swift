import SwiftUI

// <basics>
struct TextBasicsView: View {
    let plantName = "Monstera"
    let daysUntilWatering = 3
    let lastWatered = Date.now.addingTimeInterval(-4 * 86_400)
    let price = Decimal(string: "24.90") ?? 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Static text")
            Text(plantName)  // a String variable
            Text("Water \(plantName) in \(daysUntilWatering) days")  // interpolation
            Text(lastWatered, style: .relative)  // "4 days" and counting
            Text(lastWatered, format: .dateTime.day().month(.wide))  // "3 November"
            Text(price, format: .currency(code: "EUR"))  // "€24.90"
            Text(0.68, format: .percent)  // "68%"
            Text(verbatim: "No **Markdown** here")  // shown as typed
            Text("Markdown: **bold**, *italic*, `code`, [a link](https://example.com)")
        }
        .padding()
    }
}
// </basics>

#Preview { TextBasicsView() }
