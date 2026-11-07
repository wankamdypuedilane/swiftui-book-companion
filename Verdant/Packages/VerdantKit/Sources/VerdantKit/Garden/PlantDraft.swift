import Foundation

// <draft>
/// The editable state of the plant form, with its validation rules.
public struct PlantDraft: Equatable, Sendable {
    public var nickname = ""
    public var speciesName = ""
    public var speciesID: String?
    public var room = Room.livingRoom
    public var light = LightLevel.medium
    public var wateringIntervalDays = 7
    public var acquiredOn = Date()
    public var notes = ""

    public static let nicknameLength = 2...30
    public static let intervalRange = 1...60

    public enum Issue: Hashable, Sendable {
        case nicknameTooShort, nicknameTooLong, speciesMissing, intervalOutOfRange, acquiredInFuture

        public var message: String {
            switch self {
            case .nicknameTooShort: "Give your plant a name of at least 2 characters."
            case .nicknameTooLong: "Keep the name under 30 characters."
            case .speciesMissing: "Choose or type a species."
            case .intervalOutOfRange: "Water between every day and every 60 days."
            case .acquiredInFuture: "The acquisition date cannot be in the future."
            }
        }
    }

    public init() {}

    /// A draft pre-filled from an existing plant, for editing.
    public init(plant: Plant) {
        nickname = plant.nickname
        speciesName = plant.speciesName
        speciesID = plant.speciesID
        room = plant.room
        light = plant.light
        wateringIntervalDays = plant.wateringIntervalDays
        acquiredOn = plant.acquiredOn
        notes = plant.notes
    }

    /// A draft pre-filled from a catalogue species.
    public init(species: Species) {
        speciesName = species.commonName
        speciesID = species.id
        light = species.light
        wateringIntervalDays = species.wateringDays
    }

    private var trimmedNickname: String { nickname.trimmingCharacters(in: .whitespacesAndNewlines) }

    public func issues(today: Date, calendar: Calendar = .current) -> [Issue] {
        var issues: [Issue] = []
        if trimmedNickname.count < Self.nicknameLength.lowerBound { issues.append(.nicknameTooShort) }
        if trimmedNickname.count > Self.nicknameLength.upperBound { issues.append(.nicknameTooLong) }
        if speciesName.trimmingCharacters(in: .whitespaces).isEmpty { issues.append(.speciesMissing) }
        if !Self.intervalRange.contains(wateringIntervalDays) { issues.append(.intervalOutOfRange) }
        if calendar.startOfDay(for: acquiredOn) > calendar.startOfDay(for: today) {
            issues.append(.acquiredInFuture)
        }
        return issues
    }

    /// Applies the draft to an existing plant, or creates a new one.
    public func makePlant(updating existing: Plant? = nil) -> Plant {
        var plant = existing ?? Plant(nickname: "", speciesName: "", room: room,
                                      wateringIntervalDays: wateringIntervalDays,
                                      acquiredOn: acquiredOn)
        plant.nickname = trimmedNickname
        plant.speciesName = speciesName.trimmingCharacters(in: .whitespaces)
        plant.speciesID = speciesID
        plant.room = room
        plant.light = light
        plant.wateringIntervalDays = wateringIntervalDays
        plant.acquiredOn = acquiredOn
        plant.notes = notes
        return plant
    }
}
// </draft>
