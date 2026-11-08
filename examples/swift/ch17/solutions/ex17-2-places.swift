// Exercise 17.2: fetch the places and count them by kind.
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Place: Decodable {
    struct Coordinate { let latitude: Double; let longitude: Double }

    let name: String
    let kind: String
    let coordinate: Coordinate

    enum CodingKeys: String, CodingKey { case name, kind, latitude, longitude }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        kind = try container.decode(String.self, forKey: .kind)
        coordinate = Coordinate(
            latitude: try container.decode(Double.self, forKey: .latitude),
            longitude: try container.decode(Double.self, forKey: .longitude))
    }
}

let url = URL(string: "http://localhost:8080/verdant/v1/places")!
let (data, response) = try await URLSession.shared.data(from: url)
guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Unexpected status") }
let places = try JSONDecoder().decode([Place].self, from: data)
let byKind = Dictionary(grouping: places, by: \.kind)
for kind in byKind.keys.sorted() {
    print("\(kind): \(byKind[kind]!.count)")
}
let northernmost = places.max { $0.coordinate.latitude < $1.coordinate.latitude }!
print("Northernmost:", northernmost.name)
