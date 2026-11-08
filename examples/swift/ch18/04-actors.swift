// Actors protect mutable state from data races.
// <actor>
actor WaterTank {
    private(set) var litres: Int
    private(set) var log: [String] = []

    init(litres: Int) { self.litres = litres }

    /// Takes water if there is enough. Runs on the actor: one call at a time.
    func draw(_ amount: Int, for plant: String) -> Bool {
        guard litres >= amount else { return false }
        litres -= amount
        log.append(plant)
        return true
    }

    nonisolated let label = "Rain barrel"  // immutable: readable without await
}

/// 1,500 concurrent requests of 1 litre each, from many child tasks.
func drawConcurrently(from tank: WaterTank) async -> Int {
    await withTaskGroup(of: Bool.self) { group in
        for index in 0..<1_500 {
            group.addTask { await tank.draw(1, for: "plant \(index)") }
        }
        var granted = 0
        for await success in group where success { granted += 1 }
        return granted
    }
}

let tank = WaterTank(litres: 1_000)
let granted = await drawConcurrently(from: tank)
print(
    tank.label, "- granted:", granted, "- left:", await tank.litres,
    "- log entries:", await tank.log.count)
// </actor>

// <reentrancy>
// Reentrancy: state can change while an actor method is suspended at an await.
actor Greenhouse {
    var temperature = 20

    func ventilateIfHot() async -> String {
        guard temperature > 25 else { return "no need (\(temperature) °C)" }
        try? await Task.sleep(for: .milliseconds(100))  // suspension point
        // Another call may have run meanwhile: check again before acting.
        guard temperature > 25 else { return "already done" }
        temperature = 22
        return "opened the windows"
    }

    func heatUp() { temperature = 30 }
}

let greenhouse = Greenhouse()
await greenhouse.heatUp()
async let first = greenhouse.ventilateIfHot()
async let second = greenhouse.ventilateIfHot()
print(await [first, second].sorted())
// </reentrancy>
