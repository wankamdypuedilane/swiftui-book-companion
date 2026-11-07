// <plan>
/// A watering plan for one plant. Only the members marked `public` are
/// visible to code that imports GardenKit.
public struct WateringPlan: Sendable {
    public let plantName: String
    public private(set) var intervalDays: Int     // readable outside, writable inside
    var history: [Int] = []                        // internal: GardenKit only
    private let createdOnDay: Int                  // private: this type only

    public init(plantName: String, intervalDays: Int, today: Int) {
        self.plantName = plantName
        self.intervalDays = Self.validated(intervalDays)
        self.createdOnDay = today
    }

    public mutating func recordWatering(onDay day: Int) { history.append(day) }

    public mutating func adjust(toDays days: Int) { intervalDays = Self.validated(days) }

    public func nextWatering(today: Int) -> Int {
        (history.last ?? createdOnDay) + intervalDays
    }

    private static func validated(_ days: Int) -> Int { min(max(days, 1), 60) }
}
// </plan>
