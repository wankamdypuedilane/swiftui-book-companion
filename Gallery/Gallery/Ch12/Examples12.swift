import SwiftUI

extension GalleryChapter {
    static let ch12: [GalleryExample] = [
        GalleryExample("12.1", "Lazy grids") { LazyGridsView() },
        GalleryExample("12.2", "Grid") { GridLayoutView() },
        GalleryExample("12.3", "Dates") { DatesView() },
        GalleryExample("12.4", "Text input and focus") { TextInputView() },
        GalleryExample("12.5", "Reusable form components") { FormComponentsView() },
    ]
}
