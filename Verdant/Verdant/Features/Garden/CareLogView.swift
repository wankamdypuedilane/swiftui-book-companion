import SwiftUI
import VerdantKit

// <carelog>
/// The care history, newest first, with relative dates.
struct CareLogView: View {
    let events: [CareEvent]

    var body: some View {
        if events.isEmpty {
            Text("Nothing recorded yet.").foregroundStyle(.secondary)
        } else {
            ForEach(events) { event in
                HStack {
                    Image(systemName: event.kind.symbolName)
                        .foregroundStyle(.tint)
                        .frame(width: 28)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text(event.kind.title)
                        if !event.note.isEmpty {
                            Text(event.note).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text(event.date, format: .relative(presentation: .named))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}
// </carelog>
