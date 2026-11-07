// Exercise 3.2: a protocol with a default implementation and a mixed basket.
protocol Priced {
    var name: String { get }
    var priceCents: Int { get }        // money as integer cents, never Double
}

extension Priced {
    var formattedPrice: String {
        let euros = priceCents / 100, cents = priceCents % 100
        return "€\(euros).\(cents < 10 ? "0" : "")\(cents)"
    }
}

struct SeedPacket: Priced { let name: String; let priceCents: Int }
struct Pot: Priced {
    let diameterCm: Int
    var name: String { "Clay pot \(diameterCm) cm" }
    var priceCents: Int { 150 + diameterCm * 40 }
}
struct GiftCard: Priced {
    let name = "Gift card"
    let priceCents: Int
    var formattedPrice: String { "gift: €\(priceCents / 100)" }   // its own version
}

let basket: [any Priced] = [SeedPacket(name: "Basil seeds", priceCents: 295), Pot(diameterCm: 14), GiftCard(priceCents: 2000)]
for item in basket { print(item.name, "-", item.formattedPrice) }
let total = basket.reduce(0) { $0 + $1.priceCents }
print("Total: \(total) cents")
