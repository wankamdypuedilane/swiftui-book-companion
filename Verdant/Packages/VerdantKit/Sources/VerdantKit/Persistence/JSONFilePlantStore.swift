import Foundation

// <file>
/// Saves the garden as a JSON file. An actor, so that two saves can never write
/// the file at the same time.
public actor JSONFilePlantStore: PlantStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL) {
        self.fileURL = fileURL
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    /// The default location: `garden.json` in the app's Application Support folder.
    public static func defaultURL() throws -> URL {
        let folder = try FileManager.default.url(for: .applicationSupportDirectory,
                                                 in: .userDomainMask,
                                                 appropriateFor: nil, create: true)
        return folder.appendingPathComponent("garden.json")
    }

    public func load() async throws -> [Plant] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([Plant].self, from: data)
    }

    public func save(_ plants: [Plant]) async throws {
        let data = try encoder.encode(plants)
        try data.write(to: fileURL, options: [.atomic])   // never a half-written file
    }
}
// </file>
