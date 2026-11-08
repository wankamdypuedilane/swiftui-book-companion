import SwiftUI

// <deeplink>
/// Exercise 9.4: turns a URL such as verdant://rooms/Kitchen/plants/3 into routes.
enum DeepLink {
    static func routes(from url: URL, specimens: [Specimen]) -> [Route] {
        guard url.scheme == "verdant", let host = url.host() else { return [] }
        // In verdant://rooms/Kitchen the host is "rooms" and the path is "/Kitchen".
        let parts = [host] + url.pathComponents.filter { $0 != "/" }
        if parts == ["settings"] { return [.settings] }

        var routes: [Route] = []
        var rest = parts[...]  // an ArraySlice we consume in pairs
        while rest.count >= 2 {
            let kind = rest.removeFirst(), value = rest.removeFirst()
            switch kind {
            case "rooms":
                routes.append(.room(value))
            case "plants":
                let match = Int(value).flatMap { id in specimens.first { $0.id == id } }
                guard let specimen = match else { return routes }
                routes.append(.specimen(specimen))
            default:
                return routes  // unknown segment: stop here
            }
        }
        return routes
    }
}
// </deeplink>

// <addsheet>
/// Exercise 9.2: a sheet that returns a new value to its presenter through a closure.
struct AddSpecimenSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var room = "Living room"
    let onAdd: (Specimen) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Picker("Room", selection: $room) {
                    ForEach(["Bedroom", "Kitchen", "Living room"], id: \.self) { Text($0) }
                }
            }
            .navigationTitle("New plant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let id = Int.random(in: 100...999_999)
                        onAdd(Specimen(id: id, name: name, room: room))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct AddSpecimenScreen: View {
    @State private var specimens = Specimen.samples
    @State private var showsAdd = false

    var body: some View {
        NavigationStack {
            List(specimens) { Text($0.name) }
                .navigationTitle("Plants")
                .toolbar {
                    Button("Add", systemImage: "plus") { showsAdd = true }
                }
                .sheet(isPresented: $showsAdd) {
                    AddSpecimenSheet { specimens.append($0) }
                }
        }
    }
}
// </addsheet>

#Preview { AddSpecimenScreen() }
