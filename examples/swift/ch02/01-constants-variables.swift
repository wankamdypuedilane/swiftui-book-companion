// Constants, variables and type inference.
let gardenName = "Rooftop Garden"  // a constant: it can never change
var plantCount = 12  // a variable: it can change
plantCount += 3

let averageHeight: Double = 41.5  // explicit type annotation
let isOpenToday = true  // inferred as Bool

print("\(gardenName) has \(plantCount) plants.")
print("Average height: \(averageHeight) cm, open today: \(isOpenToday)")
print(type(of: plantCount), type(of: averageHeight), type(of: gardenName))

// Swift never converts between numeric types silently.
let trays = 4
let pricePerTray = 7.25
let total = Double(trays) * pricePerTray
print("Total for \(trays) trays: \(total)")
