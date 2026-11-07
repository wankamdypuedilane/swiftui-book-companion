import SwiftUI

@main
struct GalleryApp: App {
    var body: some Scene {
        WindowGroup {
            GalleryHome()
        }
    }
}

/// One example of the book, shown by the gallery.
struct GalleryExample: Identifiable {
    let listing: String          // e.g. "5.1"
    let title: String
    let content: () -> AnyView
    var id: String { listing + title }

    init<Content: View>(_ listing: String, _ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.listing = listing
        self.title = title
        self.content = { AnyView(content()) }
    }
}

struct GalleryChapter: Identifiable {
    let number: Int
    let title: String
    let examples: [GalleryExample]
    var id: Int { number }
}

struct GalleryHome: View {
    /// UI tests launch the app with `-openExample N` to open the N-th example directly.
    @State private var path: [String] = {
        let all = GalleryChapter.all.flatMap(\.examples)
        let arguments = ProcessInfo.processInfo.arguments
        guard let flag = arguments.firstIndex(of: "-openExample"), flag + 1 < arguments.count,
              let index = Int(arguments[flag + 1]) else { return [] }
        return index < all.count ? [all[index].id] : ["none"]
    }()

    var body: some View {
        NavigationStack(path: $path) {
            List(GalleryChapter.all) { chapter in
                Section("Chapter \(chapter.number): \(chapter.title)") {
                    ForEach(chapter.examples) { example in
                        NavigationLink(value: example.id) {
                            Text("\(example.listing)  \(example.title)")
                        }
                    }
                }
            }
            .navigationTitle("Gallery")
            .navigationDestination(for: String.self) { id in
                if let example = GalleryChapter.all.flatMap(\.examples).first(where: { $0.id == id }) {
                    example.content()
                        .navigationTitle(example.title)
                        .navigationBarTitleDisplayMode(.inline)
                } else {
                    Text("No more examples")
                }
            }
        }
    }
}
