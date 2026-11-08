// Arrays, dictionaries and sets.
var shoppingList = ["potting soil", "clay pot"]
shoppingList.append("fertilizer")
shoppingList.insert("gloves", at: 0)
print(shoppingList, shoppingList.count)
print(shoppingList[1], shoppingList.contains("clay pot"))
let removed = shoppingList.remove(at: 0)
print("removed \(removed):", shoppingList)

// Safe access: first/last are optionals, indices are checked.
let empty: [String] = []
print(empty.first ?? "nothing", shoppingList.indices.contains(5))

// Dictionaries map keys to values. Lookups return optionals.
var wateringDays: [String: Int] = ["Fern": 3, "Cactus": 21]
wateringDays["Pothos"] = 7
wateringDays["Cactus"] = nil  // removes the key
print(wateringDays["Fern"] ?? 0, wateringDays["Cactus"] as Any)
for (plant, days) in wateringDays.sorted(by: { $0.key < $1.key }) {
    print("  \(plant): every \(days) days")
}

// Sets store unique values without order.
let kitchen: Set = ["basil", "mint", "chives"]
let balcony: Set = ["mint", "tomato", "basil"]
print(kitchen.intersection(balcony).sorted())
print(kitchen.union(balcony).sorted())
print(kitchen.subtracting(balcony).sorted())
