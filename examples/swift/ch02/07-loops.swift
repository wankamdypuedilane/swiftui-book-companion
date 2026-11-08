// for-in, stride, while and repeat-while.
let plants = ["Fern", "Pothos", "Calathea"]
for plant in plants { print("Check \(plant)") }
for (index, plant) in plants.enumerated() { print(index + 1, plant) }

for day in stride(from: 0, to: 15, by: 7) { print("Water on day \(day)") }
for _ in 1...2 { print("Rotate the pot") }

var water = 1_000  // millilitres in the can
var round = 0
while water >= 250 {
    water -= 250
    round += 1
}
print("Rounds: \(round), left: \(water) ml")

var attempts = 0
repeat { attempts += 1 } while attempts < 3
print("attempts:", attempts)

// continue skips an iteration; a labelled break leaves an outer loop.
let grid = [[1, 0, 3], [4, 9, 6]]
search: for row in grid {
    for value in row {
        if value == 0 { continue }
        if value == 9 { print("found 9"); break search }
    }
}
