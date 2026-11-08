import SwiftUI

extension GalleryChapter {
    static let ch13: [GalleryExample] = [
        GalleryExample("13.1", "ObservableObject and @Observable") {
            ObservationComparisonView()
        },
        GalleryExample("13.2", "Environment injection") { ShopRootView() },
        GalleryExample("13.3", "Selection in a view model") { SelectionView() },
        GalleryExample("13.4", "Exercise: counter model") { CounterModelView(range: 1...5) },
    ]
}
