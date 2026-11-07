import SwiftUI

extension GalleryChapter {
    static let ch06: [GalleryExample] = [
        GalleryExample("6.1", "Image basics") { ImageBasicsView() },
        GalleryExample("6.2", "SF Symbols") { SymbolsView() },
        GalleryExample("6.3", "Clipping and masking") { ClippingMaskingView() },
        GalleryExample("6.4", "Image overlays") { ImageOverlayView() },
        GalleryExample("6.5", "Background image") { BackgroundImageView() },
        GalleryExample("6.6", "Remote image") { RemoteImageView() },
        GalleryExample("6.7", "Exercises") { ImageExercisesView() },
        GalleryExample("6.8", "Exercise: symbol variants") { VariantPicker() },
    ]
}
