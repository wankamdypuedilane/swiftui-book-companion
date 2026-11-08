import Foundation

// <status>
/// The life cycle of a report. Only town staff move a report forward; the rule is
/// written once here and once on the server, and both are tested.
public enum ReportStatus: String, Codable, CaseIterable, Sendable {
    case submitted, acknowledged, inProgress, resolved, rejected

    public var title: String {
        switch self {
        case .submitted: "Submitted"
        case .acknowledged: "Acknowledged"
        case .inProgress: "In progress"
        case .resolved: "Resolved"
        case .rejected: "Not accepted"
        }
    }

    /// The statuses this one may change into.
    public var nextStatuses: [ReportStatus] {
        switch self {
        case .submitted: [.acknowledged, .rejected]
        case .acknowledged: [.inProgress, .rejected]
        case .inProgress: [.resolved]
        case .resolved, .rejected: []
        }
    }

    public func canMove(to status: ReportStatus) -> Bool { nextStatuses.contains(status) }

    /// Still waiting for the town to act.
    public var isOpen: Bool { !nextStatuses.isEmpty }

    /// Position on the progress bar of the detail screen, from 0 to 3.
    public var step: Int {
        switch self {
        case .submitted: 0
        case .acknowledged: 1
        case .inProgress: 2
        case .resolved, .rejected: 3
        }
    }
}
// </status>
