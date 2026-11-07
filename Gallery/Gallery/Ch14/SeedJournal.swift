import SwiftData
import SwiftUI

// <model>
/// A SwiftData model: a class whose stored properties are persisted.
@Model
final class SeedPacket {
    var variety: String
    var sownOn: Date
    var germinated: Bool
    @Relationship(deleteRule: .cascade, inverse: \SeedNote.packet)
    var notes: [SeedNote] = []

    init(variety: String, sownOn: Date = .now, germinated: Bool = false) {
        self.variety = variety
        self.sownOn = sownOn
        self.germinated = germinated
    }
}

@Model
final class SeedNote {
    var text: String
    var packet: SeedPacket?  // the other side of the relationship

    init(text: String) { self.text = text }
}
// </model>

// <journal>
/// @Query fetches models and keeps the view up to date as they change.
struct SeedJournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SeedPacket.sownOn, order: .reverse) private var packets: [SeedPacket]
    @State private var showsGerminatedOnly = false

    var body: some View {
        NavigationStack {
            List {
                Toggle("Germinated only", isOn: $showsGerminatedOnly)
                SeedList(germinatedOnly: showsGerminatedOnly)
            }
            .navigationTitle("Seed journal (\(packets.count))")
            .toolbar {
                Button("Sow", systemImage: "plus") {
                    let varieties = ["Basil", "Cherry tomato", "Sunflower", "Chives"]
                    let packet = SeedPacket(variety: varieties.randomElement() ?? "Basil")
                    packet.notes.append(SeedNote(text: "Sown indoors"))
                    context.insert(packet)  // saved automatically
                }
            }
        }
    }
}

/// A child view whose query depends on a parameter: build the Query in init.
struct SeedList: View {
    @Environment(\.modelContext) private var context
    @Query private var packets: [SeedPacket]

    init(germinatedOnly: Bool) {
        let predicate = #Predicate<SeedPacket> { packet in
            !germinatedOnly || packet.germinated
        }
        _packets = Query(filter: predicate, sort: \.variety)
    }

    var body: some View {
        ForEach(packets) { packet in
            HStack {
                VStack(alignment: .leading) {
                    Text(packet.variety)
                    Text("\(packet.notes.count) note(s)").font(.caption).foregroundStyle(
                        .secondary)
                }
                Spacer()
                Button(packet.germinated ? "Germinated" : "Waiting") {
                    packet.germinated.toggle()  // a plain assignment: tracked and saved
                }
                .buttonStyle(.bordered)
            }
        }
        .onDelete { offsets in
            for index in offsets { context.delete(packets[index]) }  // cascades to notes
        }
    }
}
// </journal>

// <container>
/// The container provides the database. In an app it is attached to the window
/// group; here an in-memory store keeps the example independent.
struct SeedJournalExample: View {
    var body: some View {
        SeedJournalView()
            .modelContainer(for: SeedPacket.self, inMemory: true)
    }
}
// </container>

#Preview { SeedJournalExample() }
