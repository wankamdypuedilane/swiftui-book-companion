import Foundation

/// Fictional data for previews, tests and the first launch in demo mode.
public enum SampleData {
    /// A garden whose dates are relative to `reference`, so that previews always
    /// show a mix of thirsty and watered plants.
    public static func garden(reference: Date = .now, calendar: Calendar = .current) -> [Plant]
    {
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: reference) ?? reference
        }
        func watered(_ days: Int...) -> [CareEvent] {
            days.sorted().map { CareEvent(kind: .watered, date: daysAgo($0)) }
        }
        return [
            Plant(
                nickname: "Monty", speciesID: "monstera-deliciosa", speciesName: "Monstera",
                room: .livingRoom, light: .medium, wateringIntervalDays: 7,
                acquiredOn: daysAgo(400), careLog: watered(8, 15, 22), isFavorite: true),
            Plant(
                nickname: "Goldie", speciesID: "epipremnum-aureum",
                speciesName: "Golden pothos",
                room: .office, light: .low, wateringIntervalDays: 7,
                acquiredOn: daysAgo(200), careLog: watered(3, 10)),
            Plant(
                nickname: "Spike", speciesID: "dracaena-trifasciata",
                speciesName: "Snake plant",
                room: .bedroom, light: .low, wateringIntervalDays: 21,
                acquiredOn: daysAgo(300), careLog: watered(12)),
            Plant(
                nickname: "Fernanda", speciesID: "nephrolepis-exaltata",
                speciesName: "Boston fern",
                room: .bathroom, light: .medium, wateringIntervalDays: 3,
                acquiredOn: daysAgo(90), careLog: watered(3, 6), notes: "Mist on dry days."),
            Plant(
                nickname: "Basil", speciesID: "ocimum-basilicum", speciesName: "Sweet basil",
                room: .kitchen, light: .bright, wateringIntervalDays: 2,
                acquiredOn: daysAgo(20), careLog: watered(1)),
            Plant(
                nickname: "Prickles", speciesID: "echinopsis-oxygona",
                speciesName: "Easter lily cactus",
                room: .balcony, light: .bright, wateringIntervalDays: 14,
                acquiredOn: daysAgo(500), careLog: watered(20), isFavorite: true),
        ]
    }

    public static let species: [Species] = [
        Species(
            id: "monstera-deliciosa", commonName: "Monstera",
            scientificName: "Monstera deliciosa",
            family: "Araceae", light: .medium, wateringDays: 7, difficulty: .easy,
            petSafe: false,
            summary: "Large split leaves; let the top of the soil dry between waterings.",
            symbolName: "leaf.fill"),
        Species(
            id: "epipremnum-aureum", commonName: "Golden pothos",
            scientificName: "Epipremnum aureum",
            family: "Araceae", light: .low, wateringDays: 7, difficulty: .easy, petSafe: false,
            summary: "A forgiving trailing plant that tolerates low light.",
            symbolName: "leaf"),
        Species(
            id: "chlorophytum-comosum", commonName: "Spider plant",
            scientificName: "Chlorophytum comosum", family: "Asparagaceae", light: .medium,
            wateringDays: 7, difficulty: .easy, petSafe: true,
            summary: "Produces baby plantlets that are easy to propagate.",
            symbolName: "camera.macro"),
    ]
}
