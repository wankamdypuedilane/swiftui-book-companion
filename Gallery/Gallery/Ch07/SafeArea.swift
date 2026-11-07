import SwiftUI

// <safearea>
struct SafeAreaView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(1...30, id: \.self) { day in
                    Text("Day \(day): check the soil")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .background(Color.green.opacity(0.1).ignoresSafeArea())   // colour under the bars
        .safeAreaInset(edge: .bottom) {                            // content stays above it
            Button("Water everything") {}
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.bar)
        }
    }
}
// </safearea>

#Preview { SafeAreaView() }
