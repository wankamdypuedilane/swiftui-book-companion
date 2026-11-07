import SwiftUI

// <order>
struct ModifierOrderView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Padding, then background")
                .padding()
                .background(.yellow)

            Text("Background, then padding")
                .background(.yellow)
                .padding()

            Text("Two backgrounds")
                .padding(8)
                .background(.yellow)
                .padding(8)
                .background(.orange)

            Text("Frame, then border")
                .frame(width: 220, height: 50)
                .border(.blue)

            Text("Border, then frame")
                .border(.blue)
                .frame(width: 220, height: 50)
        }
    }
}
// </order>

#Preview { ModifierOrderView() }
