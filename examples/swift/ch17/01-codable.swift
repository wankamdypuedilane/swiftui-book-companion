// Decoding and encoding JSON with Codable.
import Foundation

// <simple>
struct Species: Codable {
    let id: String
    let commonName: String
    let wateringDays: Int
    let petSafe: Bool
}

let json = """
    {"id": "aloe-vera", "commonName": "Aloe", "wateringDays": 21, "petSafe": false}
    """
let aloe = try JSONDecoder().decode(Species.self, from: Data(json.utf8))
print(aloe.commonName, aloe.wateringDays, aloe.petSafe)
// </simple>

// <keys>
// A server using snake_case keys, a date, a missing optional value and a nested object.
struct Nursery: Codable {
    let name: String
    let openedOn: Date
    let website: URL?  // absent in the JSON: decoded as nil
    let location: Location

    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }
}

let nurseryJSON = """
    {
      "name": "The Glass Leaf",
      "opened_on": "2019-04-02T09:00:00Z",
      "location": { "latitude": 48.3905, "longitude": -4.486 }
    }
    """
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase  // opened_on -> openedOn
decoder.dateDecodingStrategy = .iso8601
let nursery = try decoder.decode(Nursery.self, from: Data(nurseryJSON.utf8))
print(nursery.name, nursery.website as Any, nursery.location.latitude)
print(nursery.openedOn.formatted(.iso8601.year().month().day()))
// </keys>

// <custom>
// CodingKeys rename properties; a custom init(from:) tolerates a messy value.
struct Reading: Decodable {
    let sensorID: String
    let moisture: Int

    enum CodingKeys: String, CodingKey {
        case sensorID = "sensor"
        case moisture
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sensorID = try container.decode(String.self, forKey: .sensorID)
        // Some sensors send "42", others 42: accept both.
        if let number = try? container.decode(Int.self, forKey: .moisture) {
            moisture = number
        } else {
            let text = try container.decode(String.self, forKey: .moisture)
            guard let number = Int(text) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .moisture, in: container, debugDescription: "Not a number: \(text)")
            }
            moisture = number
        }
    }
}

let readings = try JSONDecoder().decode(
    [Reading].self,
    from: Data(#"[{"sensor": "K1", "moisture": 42}, {"sensor": "K2", "moisture": "17"}]"#.utf8))
print(readings.map { "\($0.sensorID)=\($0.moisture)" })
// </custom>

// <errors>
// Decoding errors say exactly what is wrong and where.
do {
    _ = try JSONDecoder().decode(
        Species.self, from: Data(#"{"id": "x", "commonName": "X"}"#.utf8))
} catch DecodingError.keyNotFound(let key, let context) {
    print("Missing key:", key.stringValue, "at", context.codingPath.map(\.stringValue))
}
do {
    _ = try JSONDecoder().decode(
        Species.self,
        from: Data(#"{"id":"x","commonName":"X","wateringDays":"often","petSafe":true}"#.utf8))
} catch DecodingError.typeMismatch(let type, let context) {
    print("Type mismatch:", type, "for", context.codingPath.map(\.stringValue))
}
// </errors>

// <encode>
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
encoder.keyEncodingStrategy = .convertToSnakeCase
print(String(decoding: try encoder.encode(aloe), as: UTF8.self))
// </encode>
