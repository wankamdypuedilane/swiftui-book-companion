import SwiftUI

extension GalleryChapter {
    static let ch08: [GalleryExample] = [
        GalleryExample("8.1", "Buttons") { ButtonsView() },
        GalleryExample("8.2", "Custom button style") { CustomButtonStyleView() },
        GalleryExample("8.3", "Counter with @State") { WateringCounterView() },
        GalleryExample("8.4", "Controls and bindings") { ControlsView() },
        GalleryExample("8.5", "Favourite button with @Binding") { PlantCardView() },
        GalleryExample("8.6", "Lifting state up") { RoomFilterScreen() },
        GalleryExample("8.7", "A state mistake") { StateMistakesView() },
        GalleryExample("8.8", "Interactive form") { WorkshopSignUpView() },
        GalleryExample("8.9", "Exercises") { StateExercisesView() },
    ]
}
