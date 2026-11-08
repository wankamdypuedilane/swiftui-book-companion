import Foundation

// <coordinate>
/// A latitude and longitude in degrees. StreetPatchKit does not import Core
/// Location, so it builds and is tested on Linux; the app converts at the edge.
public struct Coordinate: Codable, Hashable, Sendable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Great-circle distance in metres (haversine formula).
    public func distance(to other: Coordinate) -> Double {
        let radians = { (degrees: Double) in degrees * .pi / 180 }
        let dLat = radians(other.latitude - latitude)
        let dLon = radians(other.longitude - longitude)
        let a =
            sin(dLat / 2) * sin(dLat / 2) + cos(radians(latitude))
            * cos(radians(other.latitude)) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * 6_371_000 * asin(min(1, a.squareRoot()))
    }
}

/// The area the town is responsible for. Reports outside it are refused.
public struct ServiceArea: Sendable {
    public var minLatitude, maxLatitude, minLongitude, maxLongitude: Double

    public static let kerbrume = ServiceArea(
        minLatitude: 48.37, maxLatitude: 48.42, minLongitude: -4.53, maxLongitude: -4.43)

    public var centre: Coordinate {
        Coordinate(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2)
    }

    public func contains(_ point: Coordinate) -> Bool {
        (minLatitude...maxLatitude).contains(point.latitude)
            && (minLongitude...maxLongitude).contains(point.longitude)
    }
}
// </coordinate>
