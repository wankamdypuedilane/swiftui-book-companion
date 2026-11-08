// Sequential and concurrent calls with async/await.
// <asynclet>
func moisture(of plant: String) async -> Int {
    try? await Task.sleep(for: .milliseconds(300))  // a slow sensor
    return plant.count * 7 % 100
}

let clock = ContinuousClock()

let sequential = await clock.measure {
    let a = await moisture(of: "Fern")  // waits 0.3 s
    let b = await moisture(of: "Cactus")  // then another 0.3 s
    print("Sequential:", a, b)
}

let concurrent = await clock.measure {
    async let a = moisture(of: "Fern")  // both start now
    async let b = moisture(of: "Cactus")
    let values = await (a, b)  // wait for both
    print("Concurrent:", values.0, values.1)
}

// Timings vary from machine to machine; the ratio does not.
let ratio = sequential / concurrent
print("Concurrent was about \(Int(ratio.rounded())) times faster")
// </asynclet>
