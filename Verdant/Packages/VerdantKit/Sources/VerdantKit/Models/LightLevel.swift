/// How much light a plant needs or receives.
public enum LightLevel: String, Codable, CaseIterable, Identifiable, Sendable, Comparable {
    case low, medium, bright

    public var id: Self { self }

    public var title: String {
        switch self {
        case .low: "Low light"
        case .medium: "Medium light"
        case .bright: "Bright light"
        }
    }

    public var symbolName: String {
        switch self {
        case .low: "sun.min"
        case .medium: "sun.haze"
        case .bright: "sun.max"
        }
    }

    /// 1 for low, 2 for medium, 3 for bright: handy for ratings and sorting.
    public var rank: Int {
        switch self {
        case .low: 1
        case .medium: 2
        case .bright: 3
        }
    }

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rank < rhs.rank }
}

/// How much care a species demands.
public enum Difficulty: String, Codable, CaseIterable, Identifiable, Sendable {
    case easy, moderate, demanding

    public var id: Self { self }
    public var title: String { rawValue.capitalized }
}
