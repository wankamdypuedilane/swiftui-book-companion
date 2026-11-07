// if, if expressions and switch.
func advise(soilMoisture: Int, lux: Int) {  // moisture in percent, light in lux
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

    let lightLevel =
        switch lux {
        case ..<500: "low"
        case 500..<2_500: "medium"
        default: "bright"
        }
    print("Light level: \(lightLevel)")
}

// switch must be exhaustive; it can match tuples and use where clauses.
func describe(_ reading: (moisture: Int, temperature: Int)) {
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
}

advise(soilMoisture: 23, lux: 1_800)
describe((moisture: 23, temperature: 31))
describe((moisture: 10, temperature: 22))

// Logical operators: && (and), || (or), ! (not)
func needsRound(isWeekend: Bool, onHoliday: Bool) -> Bool { isWeekend && !onHoliday }
print("Weekend watering round:", needsRound(isWeekend: true, onHoliday: false))
