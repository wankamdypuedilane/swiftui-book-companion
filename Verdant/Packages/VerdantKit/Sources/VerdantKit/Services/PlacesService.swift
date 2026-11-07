import Foundation

// <places>
public protocol PlacesService: Sendable {
    func places() async throws(APIError) -> [Place]
}

public struct RemotePlacesService: PlacesService {
    private let client: APIClient
    public init(client: APIClient) { self.client = client }

    public func places() async throws(APIError) -> [Place] {
        try await client.send(Endpoint<[Place]>(.get, "places"))
    }
}
// </places>
