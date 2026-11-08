// AsyncStream turns callbacks into an asynchronous sequence.
// <stream>
func moistureReadings(count: Int) -> AsyncStream<Int> {
    AsyncStream { continuation in
        let producer = Task {
            var level = 60
            for _ in 0..<count {
                try? await Task.sleep(for: .milliseconds(20))
                level -= 7  // the soil dries out
                continuation.yield(level)
            }
            continuation.finish()
        }
        continuation.onTermination = { _ in producer.cancel() }
    }
}

for await level in moistureReadings(count: 8) {
    print(level < 30 ? "Moisture \(level)% -> water now" : "Moisture \(level)%")
    if level < 20 { break }  // leaving the loop ends the stream
}
print("Done")
// </stream>
