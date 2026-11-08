import Foundation
import Observation

// <placesmodel>
/// The view model of the Map tab.
@MainActor
@Observable
public final class PlacesModel {
    public private(set) var places: [Place] = []
    public private(set) var error: APIError?
    public private(set) var isLoading = false
    public var selectedPlaceID: Place.ID?
    public var visibleKinds = Set(Place.Kind.allCases)

    @ObservationIgnored private let service: any PlacesService

    public init(service: any PlacesService) { self.service = service }

    public var visiblePlaces: [Place] { places.filter { visibleKinds.contains($0.kind) } }

    public var selectedPlace: Place? {
        selectedPlaceID.flatMap { id in places.first { $0.id == id } }
    }

    public func load() async {
        guard places.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            places = try await service.places()
            error = nil
        } catch {
            self.error = error
        }
    }

    /// Places sorted by distance from a point, with the distance in metres.
    public func nearest(
        to latitude: Double, _ longitude: Double,
        limit: Int = 3
    ) -> [(place: Place, metres: Double)] {
        visiblePlaces
            .map {
                ($0, Geo.distance(from: (latitude, longitude), to: ($0.latitude, $0.longitude)))
            }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { (place: $0.0, metres: $0.1) }
    }
}

/// Great-circle distance with the haversine formula (no MapKit needed).
public enum Geo {
    public static func distance(from a: (Double, Double), to b: (Double, Double)) -> Double {
        let earthRadius = 6_371_000.0
        let (lat1, lat2) = (a.0 * .pi / 180, b.0 * .pi / 180)
        let dLat = lat2 - lat1, dLon = (b.1 - a.1) * .pi / 180
        let h =
            sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2)
            * sin(dLon / 2)
        return 2 * earthRadius * asin(min(1, h.squareRoot()))
    }
}
// </placesmodel>
