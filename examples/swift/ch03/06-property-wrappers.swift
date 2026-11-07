// A custom property wrapper: keep a value inside a range.
@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    let range: ClosedRange<Value>
    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
    var wrappedValue: Value {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
    // The projected value is reached with the $ prefix.
    var projectedValue: Bool { value == range.lowerBound || value == range.upperBound }
}

struct Pot {
    @Clamped(0...100) var moisture = 50
    @Clamped(1...60) var wateringDays = 7
}

var pot = Pot()
pot.moisture = 140
pot.wateringDays = 0
print(pot.moisture, pot.wateringDays)
print("moisture at a limit:", pot.$moisture)
pot.moisture = 64
print(pot.moisture, pot.$moisture)
