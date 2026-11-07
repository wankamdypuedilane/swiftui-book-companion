import Foundation

// <category>
/// What kind of problem a report describes.
public enum ReportCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case pothole, streetlight, graffiti, litter, drain, signage, other

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .pothole: "Pothole or paving"
        case .streetlight: "Streetlight"
        case .graffiti: "Graffiti"
        case .litter: "Litter or bins"
        case .drain: "Blocked drain"
        case .signage: "Road sign"
        case .other: "Something else"
        }
    }

    /// An SF Symbols name. The server knows nothing about symbols: the app chooses.
    public var symbolName: String {
        switch self {
        case .pothole: "road.lanes"
        case .streetlight: "lightbulb.max"
        case .graffiti: "paintbrush"
        case .litter: "trash"
        case .drain: "drop.triangle"
        case .signage: "exclamationmark.triangle"
        case .other: "questionmark.circle"
        }
    }

    /// A category added on the server after this version shipped decodes as .other
    /// instead of making the whole list fail.
    public init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = ReportCategory(rawValue: raw) ?? .other
    }
}
// </category>
