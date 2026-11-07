import Foundation
import Observation

// <composer>
/// The New Report screen. It validates on the device, then hands the report to the
/// outbox and tries to send it at once.
@MainActor
@Observable
public final class ComposerModel {
    public enum Outcome: Equatable {
        case sent(Report)  // on the server
        case queued  // saved on the device, sent later
        case refused(String)  // the server said no; edit and try again
    }

    public var draft = ReportDraft()
    public var photo: Data?
    public private(set) var isSubmitting = false
    public private(set) var showsProblems = false  // only after the first attempt

    @ObservationIgnored private let outbox: ReportOutbox

    public init(outbox: ReportOutbox, location: Coordinate? = nil) {
        self.outbox = outbox
        draft.location = location
    }

    public var problems: [ReportDraft.Problem] { showsProblems ? draft.problems() : [] }

    public func submit() async -> Outcome? {
        showsProblems = true
        guard draft.isValid, !isSubmitting else { return nil }
        isSubmitting = true
        defer { isSubmitting = false }
        let item = await outbox.enqueue(draft, photo: photo)
        let result = await outbox.flush()
        if let report = result.sent[item.id] {
            reset()
            return .sent(report)
        }
        if let refused = await outbox.pending.first(where: { $0.id == item.id }),
            let message = refused.failure
        {
            await outbox.discard(item.id)  // the form still holds the draft to fix
            return .refused(message)
        }
        reset()
        return .queued
    }

    private func reset() {
        let location = draft.location
        draft = ReportDraft(category: draft.category, location: location)
        photo = nil
        showsProblems = false
    }
}
// </composer>
