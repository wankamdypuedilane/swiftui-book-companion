import SwiftUI

// <routes>
/// Every screen the stack can show, as a value.
enum Route: Hashable {
    case specimen(Specimen)
    case room(String)
    case settings
}
// </routes>

// <programmatic>
struct ProgrammaticNavigationView: View {
    @State private var path: [Route] = []           // the stack's content, as data

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                Button("Open the Monstera") { path.append(.specimen(Specimen.samples[0])) }
                Button("Open Kitchen, then Basil") {
                    path = [.room("Kitchen"), .specimen(Specimen.samples[2])]   // deep link
                }
                Button("Settings") { path.append(.settings) }
                Text("Depth: \(path.count)").foregroundStyle(.secondary)
            }
            .buttonStyle(.bordered)
            .navigationTitle("Programmatic")
            .navigationDestination(for: Route.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .specimen(let specimen):
            SpecimenDetail(specimen: specimen)
                .toolbar {
                    Button("Home") { path.removeAll() }          // pop to root
                }
        case .room(let room):
            List(Specimen.samples.filter { $0.room == room }) { specimen in
                NavigationLink(specimen.name, value: Route.specimen(specimen))
            }
            .navigationTitle(room)
        case .settings:
            Text("Settings").navigationTitle("Settings")
        }
    }
}
// </programmatic>

#Preview { ProgrammaticNavigationView() }
