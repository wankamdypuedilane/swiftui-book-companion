// Exercise 18.2: two data-race-free counters.

// 1. Shared state, protected by an actor.
actor Counter {
    private(set) var value = 0
    func increment() { value += 1 }
}

func countWithActor() async -> Int {
    let counter = Counter()
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<100 {
            group.addTask { await counter.increment() }
        }
    }
    return await counter.value
}

// 2. No shared state: each child returns its contribution.
func countWithResults() async -> Int {
    await withTaskGroup(of: Int.self) { group in
        for _ in 0..<100 {
            group.addTask { 1 }
        }
        return await group.reduce(0, +)
    }
}

print("Actor:", await countWithActor())
print("Results:", await countWithResults())
