import SwiftUI

// <lazy>
struct LazyStacksView: View {
    let rooms = ["Bathroom", "Bedroom", "Kitchen", "Living room", "Office"]

    var body: some View {
        ScrollView {
            // Rows are created only when they are about to appear on screen.
            LazyVStack(alignment: .leading, spacing: 8, pinnedViews: [.sectionHeaders]) {
                ForEach(rooms, id: \.self) { room in
                    Section {
                        ForEach(1...40, id: \.self) { number in
                            Text("\(room) plant #\(number)")
                                .padding(.horizontal)
                        }
                    } header: {
                        Text(room)  // sticks to the top while scrolling
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.bar)
                    }
                }
            }
        }
    }
}
// </lazy>

#Preview { LazyStacksView() }
