/// The rooms of a home where plants live.
public enum Room: String, Codable, CaseIterable, Identifiable, Sendable {
    case livingRoom, bedroom, kitchen, bathroom, office, balcony

    public var id: Self { self }

    public var title: String {
        switch self {
        case .livingRoom: "Living room"
        case .bedroom: "Bedroom"
        case .kitchen: "Kitchen"
        case .bathroom: "Bathroom"
        case .office: "Office"
        case .balcony: "Balcony"
        }
    }

    /// An SF Symbol that represents the room.
    public var symbolName: String {
        switch self {
        case .livingRoom: "sofa"
        case .bedroom: "bed.double"
        case .kitchen: "fork.knife"
        case .bathroom: "shower"
        case .office: "desktopcomputer"
        case .balcony: "sun.max"
        }
    }
}
