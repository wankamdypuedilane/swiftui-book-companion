import SwiftUI

// <basic>
/// Navigation without explicit paths: each link carries its destination view.
struct BasicNavigationView: View {
    var body: some View {
        NavigationStack {
            List(Specimen.samples) { specimen in
                NavigationLink(specimen.name) {
                    SpecimenDetail(specimen: specimen)  // built when the link is used
                }
            }
            .navigationTitle("My plants")
        }
    }
}

struct SpecimenDetail: View {
    let specimen: Specimen

    var body: some View {
        Form {
            LabeledContent("Room", value: specimen.room)
            LabeledContent("Identifier", value: specimen.id, format: .number)
        }
        .navigationTitle(specimen.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
// </basic>

#Preview { BasicNavigationView() }
