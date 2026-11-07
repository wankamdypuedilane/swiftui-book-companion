import Foundation
import Testing
@testable import VerdantKit

@Test func cacheFirstReturnsCachedDataThenRefreshes() async throws {
    let cache = MemorySpeciesCache()
    let key = SpeciesCacheKey(page: 1, query: "", light: nil)
    let old = Page(
        items: [SampleData.species[0]], page: 1, perPage: 20, total: 1,
        totalPages: 1)
    await cache.store(old, for: key)
    let service = PreviewSpeciesService()  // three species
    let repository = CacheFirstSpeciesRepository(service: service, cache: cache)

    let first = try await repository.page(1, query: nil, light: nil)
    #expect(first.isFromCache && first.page.items.count == 1)  // instant, old data
    await repository.waitForRefreshes()
    let second = try await repository.page(1, query: nil, light: nil)
    #expect(second.page.items.count == 3)  // refreshed meanwhile
}
