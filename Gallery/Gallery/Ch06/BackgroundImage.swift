import SwiftUI

// <background>
struct BackgroundImageView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Grow something today")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Track watering, discover species and meet other plant lovers.")
                .multilineTextAlignment(.center)
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image(.greenhouse)
                .resizable()
                .scaledToFill()
                .overlay(.black.opacity(0.35))  // darken for contrast
                .ignoresSafeArea()  // extend under the status bar
                .accessibilityHidden(true)
        }
    }
}
// </background>

#Preview { BackgroundImageView() }
