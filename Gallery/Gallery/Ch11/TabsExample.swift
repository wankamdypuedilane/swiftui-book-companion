import SwiftUI

// <tabs>
/// Tabs with the iOS 18 API: values for selection, a badge, a search tab and
/// user customization (rearranging tabs in the iPad sidebar).
struct TabsExampleView: View {
    enum Section: String { case home, inbox, profile, search }
    @State private var selection = Section.home
    @State private var unread = 3
    @AppStorage("galleryTabCustomization") private var customization: TabViewCustomization

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: Section.home) {
                Button("Go to the inbox") { selection = .inbox }  // from code
            }
            .customizationID("home")

            Tab("Inbox", systemImage: "tray", value: Section.inbox) {
                Button("Mark all as read") { unread = 0 }
            }
            .badge(unread)
            .customizationID("inbox")

            Tab("Profile", systemImage: "person", value: Section.profile) {
                Text("Profile")
            }
            .customizationID("profile")

            Tab(value: Section.search, role: .search) {  // the search tab
                Text("Search")
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($customization)
    }
}
// </tabs>

#Preview { TabsExampleView() }
