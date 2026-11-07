// Exercise 18.3: a countdown that stops cleanly when cancelled.
func countdown(from start: Int, onTick: @Sendable (Int) -> Void = { _ in }) async {
    do {
        for value in stride(from: start, through: 1, by: -1) {
            print(value)
            onTick(value)
            try await Task.sleep(for: .milliseconds(100))
        }
        print("Lift-off")
    } catch {
        print("cancelled")
    }
}

// Cancel the countdown once it has printed 7, whatever the speed of the machine.
let (ticks, continuation) = AsyncStream.makeStream(of: Int.self)
let task = Task { await countdown(from: 10) { continuation.yield($0) } }
for await value in ticks where value == 7 {
    task.cancel()
    break
}
await task.value
