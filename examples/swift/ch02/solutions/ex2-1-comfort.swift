// Exercise 2.1: classify a room for a tropical plant.
func comfort(temperature: Double, humidity: Int) -> String {
    switch (temperature, humidity) {
    case (..<12, _): "too cold"
    case (30..., _): "too hot"
    case (_, ..<40): "too dry"
    case (18...26, 60...): "ideal"
    default: "acceptable"
    }
}
let rooms: [(String, Double, Int)] = [
    ("Bathroom", 22, 75), ("Office", 21, 35), ("Balcony", 9, 80),
    ("Living room", 24, 50), ("Attic", 31, 55),
]
for (room, t, h) in rooms {
    print("\(room): \(comfort(temperature: t, humidity: h))")
}
