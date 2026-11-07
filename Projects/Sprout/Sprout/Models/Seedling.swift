import Foundation
import Algorithms

// <model>
/// A seedling growing in a tray. Pure data: no SwiftUI import.
struct Seedling: Identifiable, Hashable {
    let id: UUID
    var variety: String
    var sownOn: Date
    var trayPosition: Int

    init(id: UUID = UUID(), variety: String, sownOn: Date, trayPosition: Int) {
        self.id = id
        self.variety = variety
        self.sownOn = sownOn
        self.trayPosition = trayPosition
    }

    func ageInDays(on date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: sownOn)
        let end = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
}

extension Seedling {
    /// Splits seedlings into rows of a tray with `chunks(ofCount:)`,
    /// an algorithm from the swift-algorithms package.
    static func trayRows(_ seedlings: [Seedling], columns: Int) -> [[Seedling]] {
        seedlings.sorted { $0.trayPosition < $1.trayPosition }
            .chunks(ofCount: columns)
            .map(Array.init)
    }
}
// </model>

extension Seedling {
    static let samples: [Seedling] = {
        let today = Date()
        let varieties = ["Basil", "Tomato", "Chili", "Lettuce", "Parsley", "Marigold"]
        return varieties.enumerated().map { index, name in
            let sown = today.addingTimeInterval(-Double(index * 2) * 86_400)
            return Seedling(variety: name, sownOn: sown, trayPosition: index)
        }
    }()
}
