import Foundation

// <place>
/// A nursery, a plant-swap point or a community garden shown on the map.
public struct Place: Identifiable, Codable, Hashable, Sendable {
    public enum Kind: String, Codable, CaseIterable, Sendable {
        case nursery, swapPoint, garden

        public var title: String {
            switch self {
            case .nursery: "Nursery"
            case .swapPoint: "Plant swap"
            case .garden: "Community garden"
            }
        }

        public var symbolName: String {
            switch self {
            case .nursery: "storefront"
            case .swapPoint: "arrow.left.arrow.right"
            case .garden: "tree"
            }
        }
    }

    public let id: String
    public var name: String
    public var kind: Kind
    public var latitude: Double
    public var longitude: Double
    public var address: String
    public var openingHours: String

    public init(id: String, name: String, kind: Kind, latitude: Double, longitude: Double,
                address: String, openingHours: String) {
        self.id = id
        self.name = name
        self.kind = kind
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.openingHours = openingHours
    }
}
// </place>
