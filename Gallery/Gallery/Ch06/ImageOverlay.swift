import SwiftUI

// <card>
/// An image card with a readable caption: a gradient "scrim" keeps white text
/// legible whatever the colours of the photo.
struct PhotoCard: View {
    let image: ImageResource
    let title: String
    let subtitle: String

    var body: some View {
        Image(image)
            .resizable()
            .scaledToFill()
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.title2.bold())
                    Text(subtitle).font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    .linearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top, endPoint: .bottom))
            }
            .clipShape(.rect(cornerRadius: 20))
            .accessibilityElement(children: .combine)
    }
}
// </card>

struct ImageOverlayView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PhotoCard(
                    image: .greenhouse, title: "The glasshouse",
                    subtitle: "Open Saturday 10–16")
                PhotoCard(
                    image: .leaves, title: "Leaf week",
                    subtitle: "Swap your cuttings")
            }
            .padding()
        }
    }
}

#Preview { ImageOverlayView() }
