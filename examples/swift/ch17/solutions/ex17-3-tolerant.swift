// Exercise 17.3: accept a number or a {min, max} object for the same key.
import Foundation

struct Species: Decodable {
    let name: String
    let wateringDays: Int

    private struct Range: Decodable { let min: Int; let max: Int }

    enum CodingKeys: String, CodingKey { case name, wateringDays }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        if let days = try? container.decode(Int.self, forKey: .wateringDays) {
            wateringDays = days
        } else {
            let range = try container.decode(Range.self, forKey: .wateringDays)
            wateringDays = (range.min + range.max) / 2
        }
    }
}

let json = """
    [{"name": "Aloe", "wateringDays": 21},
     {"name": "Calathea", "wateringDays": {"min": 3, "max": 5}}]
    """
for species in try JSONDecoder().decode([Species].self, from: Data(json.utf8)) {
    print(species.name, species.wateringDays)
}
