// A first look at generics.
func firstDuplicate<Element: Hashable>(in items: [Element]) -> Element? {
    var seen = Set<Element>()
    for item in items {
        if !seen.insert(item).inserted { return item }
    }
    return nil
}
print(firstDuplicate(in: [3, 7, 1, 7, 3]) as Any)
print(firstDuplicate(in: ["fern", "ivy", "fern"]) as Any)
print(firstDuplicate(in: [1.5, 2.5]) as Any)

struct Stack<Element> {
    private var items: [Element] = []
    mutating func push(_ item: Element) { items.append(item) }
    mutating func pop() -> Element? { items.popLast() }
    var top: Element? { items.last }
}
var trays = Stack<String>()
trays.push("seedlings"); trays.push("cuttings")
print(trays.top as Any, trays.pop() as Any, trays.pop() as Any, trays.pop() as Any)
