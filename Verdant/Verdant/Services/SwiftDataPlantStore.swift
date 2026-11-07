import Foundation
import SwiftData
import VerdantKit

// <records>
/// The SwiftData schema. Records mirror the Plant and CareEvent values of
/// VerdantKit; the store converts between the two.
@Model
final class PlantRecord {
    @Attribute(.unique) var id: UUID
    var nickname: String
    var speciesID: String?
    var speciesName: String
    var roomRawValue: String
    var lightRawValue: String
    var wateringIntervalDays: Int
    var acquiredOn: Date
    var notes: String
    var isFavorite: Bool
    @Relationship(deleteRule: .cascade, inverse: \CareEventRecord.plant)
    var careEvents: [CareEventRecord] = []

    init(_ plant: Plant) {
        id = plant.id
        nickname = plant.nickname
        speciesID = plant.speciesID
        speciesName = plant.speciesName
        roomRawValue = plant.room.rawValue
        lightRawValue = plant.light.rawValue
        wateringIntervalDays = plant.wateringIntervalDays
        acquiredOn = plant.acquiredOn
        notes = plant.notes
        isFavorite = plant.isFavorite
    }
}

@Model
final class CareEventRecord {
    @Attribute(.unique) var id: UUID
    var kindRawValue: String
    var date: Date
    var note: String
    var plant: PlantRecord?

    init(_ event: CareEvent) {
        id = event.id
        kindRawValue = event.kind.rawValue
        date = event.date
        note = event.note
    }
}
// </records>

// <store>
/// A PlantStore backed by SwiftData. @ModelActor makes it an actor with its own
/// ModelContext, so database work never blocks the main thread.
@ModelActor
actor SwiftDataPlantStore: PlantStore {
    func load() async throws -> [Plant] {
        let descriptor = FetchDescriptor<PlantRecord>(sortBy: [SortDescriptor(\.nickname)])
        return try modelContext.fetch(descriptor).map(Self.plant(from:))
    }

    /// Saves the whole garden: updates existing records, inserts new ones and
    /// deletes the records of plants that no longer exist.
    func save(_ plants: [Plant]) async throws {
        let existing = try modelContext.fetch(FetchDescriptor<PlantRecord>())
        let byID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        let keep = Set(plants.map(\.id))
        for record in existing where !keep.contains(record.id) {
            modelContext.delete(record)                      // cascades to its events
        }
        for plant in plants {
            let record = byID[plant.id] ?? {
                let new = PlantRecord(plant)
                modelContext.insert(new)
                return new
            }()
            Self.copy(plant, into: record)
        }
        try modelContext.save()
    }

    private static func copy(_ plant: Plant, into record: PlantRecord) {
        record.nickname = plant.nickname
        record.speciesID = plant.speciesID
        record.speciesName = plant.speciesName
        record.roomRawValue = plant.room.rawValue
        record.lightRawValue = plant.light.rawValue
        record.wateringIntervalDays = plant.wateringIntervalDays
        record.acquiredOn = plant.acquiredOn
        record.notes = plant.notes
        record.isFavorite = plant.isFavorite
        let known = Set(record.careEvents.map(\.id))
        for event in plant.careLog where !known.contains(event.id) {
            record.careEvents.append(CareEventRecord(event))
        }
        let wanted = Set(plant.careLog.map(\.id))
        record.careEvents.removeAll { !wanted.contains($0.id) }
    }

    private static func plant(from record: PlantRecord) -> Plant {
        Plant(id: record.id, nickname: record.nickname, speciesID: record.speciesID,
              speciesName: record.speciesName,
              room: Room(rawValue: record.roomRawValue) ?? .livingRoom,
              light: LightLevel(rawValue: record.lightRawValue) ?? .medium,
              wateringIntervalDays: record.wateringIntervalDays, acquiredOn: record.acquiredOn,
              careLog: record.careEvents
                  .map { CareEvent(id: $0.id, kind: CareEvent.Kind(rawValue: $0.kindRawValue) ?? .watered,
                                   date: $0.date, note: $0.note) }
                  .sorted { $0.date > $1.date },
              notes: record.notes, isFavorite: record.isFavorite)
    }
}
// </store>
