// Exercise 3.4: a generic least-recently-used cache.
struct LRUCache<Key: Hashable, Value> {
    let capacity: Int
    private var values: [Key: Value] = [:]
    private var recency: [Key] = []            // oldest first

    init(capacity: Int) {
        precondition(capacity > 0, "capacity must be positive")
        self.capacity = capacity
    }

    var count: Int { values.count }
    var keysByRecency: [Key] { recency }

    mutating func value(for key: Key) -> Value? {
        guard let value = values[key] else { return nil }
        touch(key)
        return value
    }

    mutating func insert(_ value: Value, for key: Key) {
        values[key] = value
        touch(key)
        if values.count > capacity, let oldest = recency.first {
            recency.removeFirst()
            values[oldest] = nil
        }
    }

    private mutating func touch(_ key: Key) {
        recency.removeAll { $0 == key }
        recency.append(key)
    }
}

var cache = LRUCache<String, Int>(capacity: 3)
cache.insert(7, for: "pothos")
cache.insert(21, for: "zz")
cache.insert(3, for: "fern")
_ = cache.value(for: "pothos")          // pothos becomes the most recent
cache.insert(14, for: "snake")           // evicts the least recent: zz
print(cache.keysByRecency, cache.count)
print(cache.value(for: "zz") as Any, cache.value(for: "fern") as Any)
