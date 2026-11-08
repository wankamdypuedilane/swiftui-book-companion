import Foundation

// <event>
/// Something done to a plant at a given moment.
public struct CareEvent: Identifiable, Codable, Hashable, Sendable {
    public enum Kind: String, Codable, CaseIterable, Sendable {
        case watered, fertilized, repotted, pruned, misted

        public var title: String { rawValue.capitalized }

        public var symbolName: String {
            switch self {
            case .watered: "drop.fill"
            case .fertilized: "leaf.arrow.triangle.circlepath"
            case .repotted: "arrow.up.bin"
            case .pruned: "scissors"
            case .misted: "humidity"
            }
        }
    }

    public let id: UUID
    public var kind: Kind
    public var date: Date
    public var note: String

    public init(id: UUID = UUID(), kind: Kind, date: Date, note: String = "") {
        self.id = id
        self.kind = kind
        self.date = date
        self.note = note
    }
}
// </event>
