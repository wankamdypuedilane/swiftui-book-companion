import SwiftUI

// <styles>
struct TextStylesView: View {
    var body: some View {
        List {
            Section("Text styles (scale with Dynamic Type)") {
                Text("Large Title").font(.largeTitle)
                Text("Title").font(.title)
                Text("Headline").font(.headline)
                Text("Body").font(.body)
                Text("Callout").font(.callout)
                Text("Footnote").font(.footnote)
                Text("Caption").font(.caption)
            }
            Section("Weight, design and width") {
                Text("Bold title").font(.title2.bold())
                Text("Light body").font(.body.weight(.light))
                Text("Rounded design").font(.system(.title3, design: .rounded))
                Text("Serif design").font(.system(.title3, design: .serif))
                Text("Monospaced digits 12:05").font(.body.monospacedDigit())
                Text("Condensed width").font(.title3).fontWidth(.condensed)
            }
            Section("Character styles") {
                Text("Italic").italic()
                Text("Underlined").underline()
                Text("Strikethrough").strikethrough(color: .red)
                Text("Wide tracking").tracking(4)
                Text("SMALL CAPS").font(.caption.smallCaps())
            }
            Section("Custom font") {
                // Bundled in Resources/Fonts and declared under UIAppFonts in Info.plist.
                Text("Inconsolata Bold")
                    .font(.custom("Inconsolata-Bold", size: 20, relativeTo: .body))
            }
        }
    }
}
// </styles>

#Preview { TextStylesView() }
