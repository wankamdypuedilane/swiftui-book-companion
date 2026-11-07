import SwiftUI

// <value>
/// Value-based navigation: links push values, destinations are declared once per type.
struct ValueNavigationView: View {
    let rooms = ["Bedroom", "Kitchen", "Living room"]

    var body: some View {
        NavigationStack {
            List {
                Section("Plants") {
                    ForEach(Specimen.samples) { specimen in
                        NavigationLink(specimen.name, value: specimen)  // a Specimen
                    }
                }
                Section("Rooms") {
                    ForEach(rooms, id: \.self) { room in
                        NavigationLink(room, value: room)  // a String
                    }
                }
            }
            .navigationTitle("Browse")
            .navigationDestination(for: Specimen.self) { specimen in
                SpecimenDetail(specimen: specimen)
            }
            .navigationDestination(for: String.self) { room in
                List(Specimen.samples.filter { $0.room == room }) { specimen in
                    NavigationLink(specimen.name, value: specimen)  // here too
                }
                .navigationTitle(room)
            }
        }
    }
}
// </value>

#Preview { ValueNavigationView() }
