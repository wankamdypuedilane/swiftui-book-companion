import Foundation

// <protocol>
/// Where the garden is saved. The Garden model depends on this protocol only, so
/// the app can use files, SwiftData or a server, and tests can use memory.
public protocol PlantStore: Sendable {
    func load() async throws -> [Plant]
    func save(_ plants: [Plant]) async throws
}
// </protocol>

// <memory>
/// A store that keeps plants in memory: for previews and tests.
public actor InMemoryPlantStore: PlantStore {
    private var plants: [Plant]
    public private(set) var saveCount = 0

    public init(plants: [Plant] = []) { self.plants = plants }

    public func load() async throws -> [Plant] { plants }

    public func save(_ plants: [Plant]) async throws {
        self.plants = plants
        saveCount += 1
    }
}
// </memory>
