import SwiftUI

// <multiline>
struct MultilineTextView: View {
    let description = """
        The fiddle-leaf fig likes bright, indirect light and dislikes being moved. \
        Water it when the top five centimetres of soil are dry, and wipe its large \
        leaves once a month so that they can catch the light.
        """

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(description)                   // as many lines as needed

                Text(description)
                    .lineLimit(2)                       // at most two lines...
                    .truncationMode(.tail)              // ...with "…" at the end

                Text(description)
                    .lineLimit(3, reservesSpace: true)  // always 3 lines high
                    .border(.secondary)

                Text(description)
                    .multilineTextAlignment(.center)    // how lines align
                    .lineSpacing(6)                     // extra space between lines

                Text("A very long botanical name, Ficus lyrata 'Bambino'")
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)            // shrink instead of truncating
            }
            .padding()
        }
    }
}
// </multiline>

#Preview { MultilineTextView() }
