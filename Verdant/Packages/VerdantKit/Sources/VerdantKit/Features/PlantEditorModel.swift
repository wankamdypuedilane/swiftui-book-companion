import Foundation
import Observation

// <editor>
/// The view model of the plant form, used both to add and to edit a plant.
@MainActor
@Observable
public final class PlantEditorModel {
    public var draft: PlantDraft
    public private(set) var hasAttemptedSave = false
    public let isNew: Bool

    private let existing: Plant?
    private let initialDraft: PlantDraft
    private let garden: Garden
    private let now: () -> Date

    public init(garden: Garden, plant: Plant? = nil, species: Species? = nil,
                now: @escaping () -> Date = { .now }) {
        self.garden = garden
        self.existing = plant
        self.isNew = plant == nil
        self.now = now
        let start = if let plant {
            PlantDraft(plant: plant)
        } else if let species {
            PlantDraft(species: species)
        } else {
            PlantDraft()
        }
        draft = start
        initialDraft = start
    }

    public var title: String { isNew ? "New plant" : "Edit \(existing?.nickname ?? "plant")" }

    public var issues: [PlantDraft.Issue] { draft.issues(today: now()) }

    /// Messages are shown only after a first attempt to save, not while typing.
    public var visibleIssues: [PlantDraft.Issue] { hasAttemptedSave ? issues : [] }

    /// True when the user modified something: used to confirm before discarding.
    public var hasChanges: Bool { draft != initialDraft }

    /// Saves the draft and returns the saved plant, or nil if the draft is invalid.
    @discardableResult
    public func save() async -> Plant? {
        hasAttemptedSave = true
        guard issues.isEmpty else { return nil }
        let plant = draft.makePlant(updating: existing)
        if isNew {
            await garden.add(plant)
        } else {
            await garden.update(plant)
        }
        return plant
    }
}
// </editor>
