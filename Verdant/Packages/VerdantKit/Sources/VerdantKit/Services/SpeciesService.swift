import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// <service>
/// The catalogue as seen by the rest of the app. Views and view models depend on
/// this protocol, never on URLs or JSON.
public protocol SpeciesService: Sendable {
    func species(
        page: Int, perPage: Int, query: String?, light: LightLevel?
    )
        async throws(APIError) -> Page<Species>
    func species(id: Species.ID) async throws(APIError) -> Species
}

/// The implementation that calls the Verdant API.
public struct RemoteSpeciesService: SpeciesService {
    private let client: APIClient

    public init(client: APIClient) { self.client = client }

    public func species(
        page: Int, perPage: Int = 20, query: String? = nil,
        light: LightLevel? = nil
    ) async throws(APIError) -> Page<Species> {
        var items = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "perPage", value: String(perPage)),
        ]
        if let query, !query.isEmpty { items.append(URLQueryItem(name: "q", value: query)) }
        if let light { items.append(URLQueryItem(name: "light", value: light.rawValue)) }
        return try await client.send(Endpoint<Page<Species>>(.get, "species", query: items))
    }

    public func species(id: Species.ID) async throws(APIError) -> Species {
        try await client.send(Endpoint<Species>(.get, "species/\(id)"))
    }
}
// </service>
