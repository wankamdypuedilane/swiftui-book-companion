import SwiftUI

// <clipping>
struct ClippingMaskingView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(.pottedPlant)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(.circle)  // clip to a shape
                    .overlay { Circle().stroke(.white, lineWidth: 4) }  // ring on top
                    .shadow(radius: 6)

                Image(.leaves)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .mask {  // fade to transparent
                        LinearGradient(
                            colors: [.black, .clear],
                            startPoint: .top, endPoint: .bottom)
                    }

                Text("VERDANT")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(.clear)
                    .background {
                        Image(.leaves).resizable().scaledToFill()
                    }
                    .mask {  // image shows through text
                        Text("VERDANT")
                            .font(.system(size: 64, weight: .black, design: .rounded))
                    }
            }
            .padding()
        }
    }
}
// </clipping>

#Preview { ClippingMaskingView() }
