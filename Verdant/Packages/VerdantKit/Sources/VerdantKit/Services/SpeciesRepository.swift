import Foundation

// <repository>
/// Combines the network and a local cache. Successful pages are cached; when the
/// network fails, the cached copy is returned and marked as stale.
public actor SpeciesRepository {
    public struct Result: Sendable {
        public var page: Page<Species>
        public var isFromCache: Bool
    }

    private let service: any SpeciesService
    private let cache: any SpeciesCache

    public init(service: any SpeciesService, cache: any SpeciesCache) {
        self.service = service
        self.cache = cache
    }

    public func page(
        _ number: Int, query: String?, light: LightLevel?
    ) async throws(APIError) -> Result {
        let key = SpeciesCacheKey(page: number, query: query ?? "", light: light)
        do {
            let page = try await service.species(
                page: number, perPage: 20, query: query, light: light)
            await cache.store(page, for: key)
            return Result(page: page, isFromCache: false)
        } catch  where error.isRetryable {
            if let cached = await cache.page(for: key) {
                return Result(page: cached, isFromCache: true)
            }
            throw error
        }
    }
}

public struct SpeciesCacheKey: Hashable, Codable, Sendable {
    public var page: Int
    public var query: String
    public var light: LightLevel?

    var fileName: String {
        let safeQuery = query.lowercased().filter { $0.isLetter || $0.isNumber }
        return "species-\(page)-\(safeQuery)-\(light?.rawValue ?? "any").json"
    }
}

public protocol SpeciesCache: Sendable {
    func page(for key: SpeciesCacheKey) async -> Page<Species>?
    func store(_ page: Page<Species>, for key: SpeciesCacheKey) async
}

/// Keeps pages in memory: for tests and previews.
public actor MemorySpeciesCache: SpeciesCache {
    private var pages: [SpeciesCacheKey: Page<Species>] = [:]
    public init() {}
    public func page(for key: SpeciesCacheKey) async -> Page<Species>? { pages[key] }
    public func store(_ page: Page<Species>, for key: SpeciesCacheKey) async {
        pages[key] = page
    }
}

/// Keeps pages as JSON files in the Caches folder, which the system may purge.
public actor FileSpeciesCache: SpeciesCache {
    private let folder: URL

    public init(folder: URL) { self.folder = folder }

    public static func defaultFolder() throws -> URL {
        try FileManager.default.url(
            for: .cachesDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        )
        .appendingPathComponent("species", isDirectory: true)
    }

    public func page(for key: SpeciesCacheKey) async -> Page<Species>? {
        let url = folder.appendingPathComponent(key.fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? APIClient.makeDecoder().decode(Page<Species>.self, from: data)
    }

    public func store(_ page: Page<Species>, for key: SpeciesCacheKey) async {
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        guard let data = try? APIClient.makeEncoder().encode(page) else { return }
        try? data.write(to: folder.appendingPathComponent(key.fileName), options: .atomic)
    }
}
// </repository>
