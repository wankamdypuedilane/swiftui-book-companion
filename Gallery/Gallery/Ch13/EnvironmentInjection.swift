import SwiftUI

// <environment>
@Observable
final class Basket {
    var items: [String] = []
}

/// The root creates the object once and places it in the environment.
struct ShopRootView: View {
    @State private var basket = Basket()

    var body: some View {
        NavigationStack {
            ProductListView()
                .toolbar { BasketBadge() }
        }
        .environment(basket)  // every descendant can read it
    }
}

struct ProductListView: View {
    @Environment(Basket.self) private var basket  // read by type, no parameter

    var body: some View {
        List(["Terracotta pot", "Potting mix", "Mister"], id: \.self) { product in
            Button("Add \(product)") { basket.items.append(product) }
        }
        .navigationTitle("Shop")
    }
}

struct BasketBadge: View {
    @Environment(Basket.self) private var basket

    var body: some View {
        Label("\(basket.items.count)", systemImage: "basket")
            .labelStyle(.titleAndIcon)
    }
}
// </environment>

#Preview { ShopRootView() }
