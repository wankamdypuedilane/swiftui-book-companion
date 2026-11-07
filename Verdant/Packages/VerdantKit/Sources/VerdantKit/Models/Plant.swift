import Foundation

// <plant>
/// A plant that the user keeps at home.
public struct Plant: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var nickname: String
    public var speciesID: String?  // set when chosen from the catalogue
    public var speciesName: String
    public var room: Room
    public var light: LightLevel
    public var wateringIntervalDays: Int
    public var acquiredOn: Date
    public var careLog: [CareEvent]  // newest first
    public var notes: String
    public var isFavorite: Bool

    public init(
        id: UUID = UUID(), nickname: String, speciesID: String? = nil,
        speciesName: String, room: Room, light: LightLevel = .medium,
        wateringIntervalDays: Int, acquiredOn: Date,
        careLog: [CareEvent] = [], notes: String = "", isFavorite: Bool = false
    ) {
        self.id = id
        self.nickname = nickname
        self.speciesID = speciesID
        self.speciesName = speciesName
        self.room = room
        self.light = light
        self.wateringIntervalDays = wateringIntervalDays
        self.acquiredOn = acquiredOn
        self.careLog = careLog
        self.notes = notes
        self.isFavorite = isFavorite
    }

    /// The date of the most recent watering, if any.
    public var lastWatered: Date? {
        careLog.lazy.filter { $0.kind == .watered }.map(\.date).max()
    }

    /// Records a care event, keeping the log sorted from newest to oldest.
    public mutating func record(_ event: CareEvent) {
        let index = careLog.firstIndex { $0.date < event.date } ?? careLog.endIndex
        careLog.insert(event, at: index)
    }
}
// </plant>
