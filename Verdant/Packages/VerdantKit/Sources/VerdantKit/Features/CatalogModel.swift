import Foundation
import Observation

// <catalog>
/// The view model of the Catalogue tab: paginated, searchable, filterable,
/// with loading, error, empty and offline states.
@MainActor
@Observable
public final class CatalogModel {
    public enum Phase: Equatable {
        case idle, loading, loaded, failed(APIError)
    }

    public private(set) var species: [Species] = []
    public private(set) var phase = Phase.idle
    public private(set) var isLoadingMore = false
    public private(set) var isShowingCachedData = false
    public private(set) var canLoadMore = false
    public var query = ""
    public var lightFilter: LightLevel?

    @ObservationIgnored private let repository: SpeciesRepository
    @ObservationIgnored private var nextPage = 1
    @ObservationIgnored private var loadedQuery: (String, LightLevel?)?

    public init(repository: SpeciesRepository) {
        self.repository = repository
    }

    public var isEmpty: Bool { phase == .loaded && species.isEmpty }

    /// Loads the first page for the current query and filter, replacing the list.
    public func reload() async {
        let request = (query.trimmingCharacters(in: .whitespaces), lightFilter)
        phase = .loading
        do {
            let result = try await repository.page(1, query: request.0, light: request.1)
            guard !Task.isCancelled else { return }       // a newer search replaced this one
            species = result.page.items
            canLoadMore = result.page.hasMore
            isShowingCachedData = result.isFromCache
            nextPage = 2
            loadedQuery = request
            phase = .loaded
        } catch {
            guard error != .cancelled, !Task.isCancelled else { return }
            phase = .failed(error)
        }
    }

    /// Called when a row appears: loads the next page when the last row is shown.
    public func loadMoreIfNeeded(after item: Species) async {
        guard item.id == species.last?.id, canLoadMore, !isLoadingMore,
              phase == .loaded, let (query, light) = loadedQuery else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let result = try await repository.page(nextPage, query: query, light: light)
            let known = Set(species.map(\.id))
            species += result.page.items.filter { !known.contains($0.id) }
            canLoadMore = result.page.hasMore
            isShowingCachedData = isShowingCachedData || result.isFromCache
            nextPage += 1
        } catch {
            canLoadMore = false                // stop asking; pull to refresh retries
        }
    }
}
// </catalog>
