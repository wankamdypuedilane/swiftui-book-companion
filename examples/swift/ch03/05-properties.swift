// Stored, computed, lazy and static properties; property observers.
struct WaterTank {
    static let maximum = 5_000  // shared by all tanks
    var level = 2_000 {
        willSet { if newValue < 500 { print("warning: level will drop to \(newValue) ml") } }
        didSet {
            if level > Self.maximum { level = Self.maximum }  // clamp
            print("level changed from \(oldValue) to \(level) ml")
        }
    }
    var percent: Double {  // computed, read-write
        get { Double(level) / Double(Self.maximum) * 100 }
        set { level = Int(newValue / 100 * Double(Self.maximum)) }
    }
}

var tank = WaterTank()
tank.level -= 1_700
tank.level += 9_000
tank.percent = 50
print(tank.level, tank.percent)

final class Report {
    // A lazy property is computed the first time it is read.
    lazy var expensiveSummary: String = {
        print("(computing summary...)")
        return "42 plants, 3 thirsty"
    }()
}
let report = Report()
print("report created")
print(report.expensiveSummary)
print(report.expensiveSummary)
