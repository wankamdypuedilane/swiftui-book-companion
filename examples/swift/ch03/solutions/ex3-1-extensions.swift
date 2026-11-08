// Exercise 3.1: small extensions on standard types.
extension Double {
    var fahrenheit: Double { self * 9 / 5 + 32 }
    func rounded(toPlaces places: Int) -> Double {
        var factor = 1.0
        for _ in 0..<places { factor *= 10 }
        return (self * factor).rounded() / factor
    }
}

extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}

for celsius in [-5.0, 18.5, 24.0] {
    print("\(celsius) °C = \(celsius.fahrenheit.rounded(toPlaces: 1)) °F")
}
print([1, 2].isNotEmpty, "".isNotEmpty, [String: Int]().isNotEmpty)
