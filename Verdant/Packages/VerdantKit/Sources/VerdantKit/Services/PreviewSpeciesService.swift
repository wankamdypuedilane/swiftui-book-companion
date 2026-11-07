import Foundation

/// Exercise 19.1: a species service for previews, with no network.
public struct PreviewSpeciesService: SpeciesService {
    public var species: [Species]

    public init(species: [Species] = SampleData.species) { self.species = species }

    public func species(
        page: Int, perPage: Int, query: String?, light: LightLevel?
    )
        async throws(APIError) -> Page<Species>
    {
        let text = query?.trimmingCharacters(in: .whitespaces) ?? ""
        let matches = species.filter {
            (text.isEmpty || $0.commonName.localizedStandardContains(text))
                && (light == nil || $0.light == light)
        }
        return Page(
            items: page == 1 ? matches : [], page: page, perPage: perPage,
            total: matches.count, totalPages: 1)
    }

    public func species(id: Species.ID) async throws(APIError) -> Species {
        guard let match = species.first(where: { $0.id == id }) else {
            throw .http(status: 404, message: "Unknown species.")
        }
        return match
    }
}
