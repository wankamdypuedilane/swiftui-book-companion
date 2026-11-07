// Generics in depth: associated types, constraints and where clauses.
protocol Store {
    associatedtype Item: Identifiable
    mutating func save(_ item: Item)
    func item(withID id: Item.ID) -> Item?
    var all: [Item] { get }
}

struct MemoryStore<Item: Identifiable>: Store {
    private var storage: [Item.ID: Item] = [:]
    private var order: [Item.ID] = []
    mutating func save(_ item: Item) {
        if storage[item.id] == nil { order.append(item.id) }
        storage[item.id] = item
    }
    func item(withID id: Item.ID) -> Item? { storage[id] }
    var all: [Item] { order.compactMap { storage[$0] } }
}

struct Species: Identifiable { let id: String; let commonName: String; let wateringDays: Int }

// A generic function constrained with a where clause.
func names<S: Store>(in store: S, where predicate: (S.Item) -> Bool) -> [String]
where S.Item == Species {
    store.all.filter(predicate).map(\.commonName)
}

var catalog = MemoryStore<Species>()
catalog.save(Species(id: "pothos", commonName: "Golden pothos", wateringDays: 7))
catalog.save(Species(id: "zz", commonName: "ZZ plant", wateringDays: 21))
catalog.save(Species(id: "fern", commonName: "Boston fern", wateringDays: 3))
catalog.save(Species(id: "pothos", commonName: "Pothos", wateringDays: 7))   // replaces

print(catalog.all.map(\.commonName))
print(catalog.item(withID: "zz")?.wateringDays as Any)
print(names(in: catalog) { $0.wateringDays <= 7 })

// Conditional conformance: a Pair is Equatable only when its elements are.
struct Pair<A, B> { let first: A; let second: B }
extension Pair: Equatable where A: Equatable, B: Equatable {}
print(Pair(first: 1, second: "a") == Pair(first: 1, second: "a"))
