import SwiftUI

// <rating>
/// Exercise 6.4: a light-requirement rating drawn with SF Symbols, supporting
/// fractional values such as 2.5 by masking a filled row.
struct SunRating: View {
    let value: Double          // 0...maximum
    var maximum = 3

    var body: some View {
        let symbols = HStack(spacing: 2) {
            ForEach(0..<maximum, id: \.self) { _ in Image(systemName: "sun.max.fill") }
        }
        symbols
            .foregroundStyle(.quaternary)
            .overlay(alignment: .leading) {
                symbols
                    .foregroundStyle(.orange)
                    .mask(alignment: .leading) {
                        GeometryReader { proxy in
                            let fraction = value / Double(maximum)
                            Rectangle().frame(width: proxy.size.width * fraction)
                        }
                    }
            }
            .accessibilityElement()
            .accessibilityLabel("Light: \(value.formatted()) out of \(maximum)")
    }
}
// </rating>

// <favorite>
/// Exercise 6.2: a plant thumbnail with a favourite badge.
struct PlantThumbnail: View {
    let image: ImageResource
    let name: String
    let isFavorite: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(.rect(cornerRadius: 18))
                .overlay(alignment: .topTrailing) {
                    if isFavorite {
                        Image(systemName: "star.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .yellow)
                            .font(.title2)
                            .offset(x: 8, y: -8)
                            .accessibilityLabel("Favourite")
                    }
                }
            Text(name).font(.caption).lineLimit(1)
        }
        .frame(width: 104)
    }
}
// </favorite>

struct ImageExercisesView: View {
    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 16) {
                PlantThumbnail(image: .pottedPlant, name: "Pothos", isFavorite: true)
                PlantThumbnail(image: .leaves, name: "Calathea", isFavorite: false)
            }
            VStack(alignment: .leading, spacing: 12) {
                SunRating(value: 1)
                SunRating(value: 2.5)
                SunRating(value: 3)
            }
            .font(.title)
        }
        .padding()
    }
}

#Preview { ImageExercisesView() }
