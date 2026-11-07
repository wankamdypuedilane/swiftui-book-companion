import SwiftUI

extension GalleryChapter {
    static let ch07: [GalleryExample] = [
        GalleryExample("7.1", "Basic shapes") { ShapesView() },
        GalleryExample("7.2", "Custom shapes") { CustomShapesView() },
        GalleryExample("7.3", "Stacks") { StacksView() },
        GalleryExample("7.4", "Frames and padding") { FramesPaddingView() },
        GalleryExample("7.5", "Safe area") { SafeAreaView() },
        GalleryExample("7.6", "Lazy stacks") { LazyStacksView() },
        GalleryExample("7.7", "Responsive layout") { ResponsiveLayoutView() },
        GalleryExample("7.8", "Composition") { GardenDashboard() },
        GalleryExample("7.9", "Exercises: badge and timeline") { LayoutExercisesView() },
        GalleryExample("7.10", "Exercise: flow layout") { FlowLayoutView() },
    ]
}
