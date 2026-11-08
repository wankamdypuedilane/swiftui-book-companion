import SwiftUI

// <favorite>
/// A reusable button that reads and writes a Boolean it does not own.
struct FavoriteButton: View {
    @Binding var isFavorite: Bool

    var body: some View {
        Button {
            isFavorite.toggle()  // writes through the binding to the owner
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? .red : .secondary)
                .symbolEffect(.bounce, value: isFavorite)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove from favourites" : "Add to favourites")
    }
}
// </favorite>

// <owner>
/// The parent owns the state and passes a binding to the child with `$`.
struct PlantCardView: View {
    @State private var isFavorite = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Boston fern").font(.headline)
                Text(isFavorite ? "In your favourites" : "Not a favourite")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            FavoriteButton(isFavorite: $isFavorite)
                .font(.title)
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 16))
        .padding()
    }
}
// </owner>

#Preview { PlantCardView() }
#Preview("Button alone") {
    @Previewable @State var on = true
    FavoriteButton(isFavorite: $on).font(.largeTitle)
}
