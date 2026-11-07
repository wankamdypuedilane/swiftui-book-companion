import Foundation

/// Exercise 19.2: return cached data at once, refresh it in the background.
public actor CacheFirstSpeciesRepository {
    private let service: any SpeciesService
    private let cache: any SpeciesCache
    private var refreshes: [SpeciesCacheKey: Task<Void, Never>] = [:]

    public init(service: any SpeciesService, cache: any SpeciesCache) {
        self.service = service
        self.cache = cache
    }

    public func page(
        _ number: Int, query: String?, light: LightLevel?
    )
        async throws(APIError) -> SpeciesRepository.Result
    {
        let key = SpeciesCacheKey(page: number, query: query ?? "", light: light)
        if let cached = await cache.page(for: key) {
            refreshInBackground(key: key)  // for the next call
            return SpeciesRepository.Result(page: cached, isFromCache: true)
        }
        let page = try await service.species(
            page: number, perPage: 20, query: query,
            light: light)
        await cache.store(page, for: key)
        return SpeciesRepository.Result(page: page, isFromCache: false)
    }

    /// Waits for the background refreshes started so far (used by tests).
    public func waitForRefreshes() async {
        for task in refreshes.values { await task.value }
    }

    private func refreshInBackground(key: SpeciesCacheKey) {
        guard refreshes[key] == nil else { return }  // one refresh at a time
        let (service, cache) = (service, cache)
        refreshes[key] = Task {
            if let fresh = try? await service.species(
                page: key.page, perPage: 20, query: key.query, light: key.light)
            {
                await cache.store(fresh, for: key)
            }
            self.finishRefresh(key)
        }
    }

    private func finishRefresh(_ key: SpeciesCacheKey) { refreshes[key] = nil }
}
