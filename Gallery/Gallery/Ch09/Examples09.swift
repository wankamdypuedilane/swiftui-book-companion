import SwiftUI

extension GalleryChapter {
    static let ch09: [GalleryExample] = [
        GalleryExample("9.1", "Basic navigation") { BasicNavigationView() },
        GalleryExample("9.2", "Value-based navigation") { ValueNavigationView() },
        GalleryExample("9.3", "Programmatic navigation") { ProgrammaticNavigationView() },
        GalleryExample("9.4", "Toolbars") { ToolbarsView() },
        GalleryExample("9.5", "Sheets and covers") { SheetsView() },
        GalleryExample("9.6", "Alerts and dialogs") { AlertsView() },
        GalleryExample("9.7", "Editing through navigation") { EditableListView() },
        GalleryExample("9.8", "Exercise: add sheet") { AddSpecimenScreen() },
    ]
}
