import SwiftUI

// <basics>
struct ImageBasicsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. Resizable and scaled to fit: the whole image is visible.
                Image(.leaves)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .border(.secondary)

                // 2. Scaled to fill and clipped: the frame is covered, edges are cut.
                Image(.leaves)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 120)
                    .clipped()

                // 3. A fixed aspect ratio, independent of the image's own ratio.
                Image(.greenhouse)
                    .resizable()
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .frame(width: 300)
                    .clipShape(.rect(cornerRadius: 16))

                // 4. Without .resizable(), an image keeps its pixel size.
                Image(.pottedPlant)
                    .frame(width: 120, height: 120)
                    .clipped()
                    .accessibilityLabel("A potted plant")
            }
            .padding()
        }
    }
}
// </basics>

#Preview { ImageBasicsView() }
