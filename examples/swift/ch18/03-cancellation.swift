// Cooperative cancellation.
// <cancel>
func water(_ plants: [String]) async throws -> Int {
    var watered = 0
    for plant in plants {
        try Task.checkCancellation()  // stop between two plants
        try await Task.sleep(for: .milliseconds(100))  // also throws when cancelled
        print("Watered \(plant)")
        watered += 1
    }
    return watered
}

let plants = ["Fern", "Pothos", "Basil", "Mint", "Cactus", "Monstera"]
let task = Task { try await water(plants) }
try await Task.sleep(for: .milliseconds(250))
task.cancel()  // a request, not an interruption
switch await task.result {
case .success(let count): print("Finished: \(count)")
case .failure(let error): print("Stopped by", type(of: error))
}

// A task that ignores cancellation runs to the end.
let stubborn = Task {
    var total = 0
    for value in 1...3 {
        try? await Task.sleep(for: .milliseconds(50))  // error ignored with try?
        total += value
    }
    return total
}
stubborn.cancel()
print("Stubborn task result:", await stubborn.value, "(cancelled: \(stubborn.isCancelled))")
// </cancel>
