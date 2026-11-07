import Foundation

// <species>
/// A plant species from the Verdant catalogue (served by the API).
public struct Species: Identifiable, Codable, Hashable, Sendable {
    public let id: String                 // a stable slug, e.g. "monstera-deliciosa"
    public var commonName: String
    public var scientificName: String
    public var family: String
    public var light: LightLevel
    public var wateringDays: Int
    public var difficulty: Difficulty
    public var petSafe: Bool
    public var summary: String
    public var symbolName: String

    public init(id: String, commonName: String, scientificName: String, family: String,
                light: LightLevel, wateringDays: Int, difficulty: Difficulty,
                petSafe: Bool, summary: String, symbolName: String = "leaf") {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.family = family
        self.light = light
        self.wateringDays = wateringDays
        self.difficulty = difficulty
        self.petSafe = petSafe
        self.summary = summary
        self.symbolName = symbolName
    }
}
// </species>

// <page>
/// One page of a paginated API response.
public struct Page<Item: Codable & Sendable>: Codable, Sendable {
    public var items: [Item]
    public var page: Int
    public var perPage: Int
    public var total: Int
    public var totalPages: Int

    public init(items: [Item], page: Int, perPage: Int, total: Int, totalPages: Int) {
        self.items = items
        self.page = page
        self.perPage = perPage
        self.total = total
        self.totalPages = totalPages
    }

    public var hasMore: Bool { page < totalPages }
}
// </page>
