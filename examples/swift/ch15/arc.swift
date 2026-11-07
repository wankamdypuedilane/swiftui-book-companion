// Automatic reference counting, reference cycles, weak and unowned references.

// <cycle>
final class Gardener {
    let name: String
    var plot: Plot?  // strong reference to the plot
    init(name: String) { self.name = name }
    deinit { print("Gardener \(name) released") }
}

final class Plot {
    let number: Int
    var tenant: Gardener?  // strong: creates a cycle with Gardener.plot
    init(number: Int) { self.number = number }
    deinit { print("Plot \(number) released") }
}

do {
    let amina = Gardener(name: "Amina")
    let plot = Plot(number: 7)
    amina.plot = plot
    plot.tenant = amina  // each keeps the other alive
}
print("After the first block: nothing was released (a leak)")
// </cycle>

// <weak>
final class Allotment {
    let number: Int
    weak var tenant: Gardener?  // weak: does not keep the gardener alive
    init(number: Int) { self.number = number }
    deinit { print("Allotment \(number) released") }
}

let allotment = Allotment(number: 12)
do {
    let yann = Gardener(name: "Yann")
    allotment.tenant = yann
    print("Tenant while Yann exists:", allotment.tenant?.name ?? "none")
}
print("Tenant after Yann was released:", allotment.tenant?.name ?? "none")

// unowned: a non-optional reference to an object that always outlives this one.
final class Tray {
    let label: String
    var seedlings: [Seedling] = []
    init(label: String) { self.label = label }
    deinit { print("Tray \(label) released") }
}

final class Seedling {
    let name: String
    unowned let tray: Tray  // a seedling never outlives its tray
    init(name: String, tray: Tray) {
        self.name = name
        self.tray = tray
    }
    deinit { print("Seedling \(name) released") }
}

do {
    let tray = Tray(label: "A")
    tray.seedlings = [Seedling(name: "Basil", tray: tray)]
    print("\(tray.seedlings[0].name) is in tray \(tray.seedlings[0].tray.label)")
}
// </weak>

// <closures>
final class WateringTimer {
    let plant: String
    var onTick: (() -> Void)?
    init(plant: String) { self.plant = plant }
    deinit { print("Timer for \(plant) released") }

    func startLeaking() {
        onTick = { print("Water \(self.plant)") }  // closure captures self strongly
    }

    func startSafely() {
        onTick = { [weak self] in  // capture list: weak self
            guard let self else { return }
            print("Water \(self.plant)")
        }
    }
}

do {
    let leaking = WateringTimer(plant: "Fern")
    leaking.startLeaking()
    leaking.onTick?()
}
print("The fern timer was not released: self -> closure -> self")
do {
    let safe = WateringTimer(plant: "Cactus")
    safe.startSafely()
    safe.onTick?()
}
print("End of program")
// </closures>
