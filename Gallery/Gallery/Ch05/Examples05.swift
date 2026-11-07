import SwiftUI

extension GalleryChapter {
    static let ch05: [GalleryExample] = [
        GalleryExample("5.1", "Text basics") { TextBasicsView() },
        GalleryExample("5.2", "Multiline text") { MultilineTextView() },
        GalleryExample("5.3", "Text styles") { TextStylesView() },
        GalleryExample("5.4", "Colors and backgrounds") { TextColorsView() },
        GalleryExample("5.5", "Modifier order") { ModifierOrderView() },
        GalleryExample("5.6", "Accessible text") { AccessibleTextView() },
        GalleryExample("5.7", "Reusable typography") { TypographyStylesView() },
        GalleryExample("5.8", "Exercise: price tag") { PriceTagExercise() },
        GalleryExample("5.9", "Exercise: care card") { CareCardExercise() },
        GalleryExample("5.10", "Exercise: adaptive header") { AdaptiveHeaderExercise() },
    ]
}
