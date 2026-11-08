import SwiftUI

extension GalleryChapter {
    static let ch11: [GalleryExample] = [
        GalleryExample("11.1", "Static list") { StaticListView() },
        GalleryExample("11.2", "Dynamic list") { DynamicListView() },
        GalleryExample("11.3", "Rows, swipes, menus") { CustomRowsView() },
        GalleryExample("11.4", "Search, filter, sort") { SearchFilterSortView() },
        GalleryExample("11.5", "Loading states") { LoadingStatesView() },
        GalleryExample("11.6", "Tabs") { TabsExampleView() },
    ]
}
