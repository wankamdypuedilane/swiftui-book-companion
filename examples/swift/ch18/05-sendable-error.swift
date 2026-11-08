// expect: compile-error
// In the Swift 6 language mode, sharing mutable state across tasks does not compile.
final class Counter {  // a class with mutable state: not Sendable
    var value = 0
}

func countConcurrently() async {
    let counter = Counter()
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<100 {
            group.addTask { counter.value += 1 }  // a data race: rejected
        }
    }
    print(counter.value)
}
