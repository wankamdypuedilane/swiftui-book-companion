// if, if expressions and switch.
let soilMoisture = 23   // percent

if soilMoisture < 20 {
    print("Water now")
} else if soilMoisture < 40 {
    print("Water soon")
} else {
    print("No water needed")
}

// if and switch can be used as expressions (Swift 5.9 and later).
let advice = if soilMoisture < 30 { "dry" } else { "moist" }
print("Soil is \(advice)")

let lux = 1_800
let lightLevel = switch lux {
case ..<500: "low"
case 500..<2_500: "medium"
default: "bright"
}
print("Light level: \(lightLevel)")

// switch must be exhaustive; it can match tuples and use where clauses.
let reading = (moisture: 23, temperature: 31)
switch reading {
case (let m, _) where m < 15:
    print("Very dry (\(m)%)")
case (_, 30...):
    print("Hot room: check daily")
case (20..<40, _):
    print("Normal")
default:
    print("Other")
}

// Logical operators: && (and), || (or), ! (not)
let isWeekend = true, onHoliday = false
if isWeekend && !onHoliday { print("Weekend watering round") }
