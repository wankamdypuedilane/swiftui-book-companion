import Combine
import SwiftUI

// <pipeline>
/// A search model built with Combine: publishers, operators and a subscriber.
final class SpeciesSearch: ObservableObject {
    @Published var query = ""  // $query is a publisher of its values
    @Published private(set) var results: [String] = []
    @Published private(set) var searchCount = 0
    private var cancellables = Set<AnyCancellable>()

    private let catalogue = [
        "Aloe", "Areca palm", "Basil", "Begonia", "Boston fern",
        "Calathea", "Monstera", "Pothos", "Snake plant", "ZZ plant",
    ]

    init() {
        $query
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .removeDuplicates()  // ignore repeated values
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)  // wait for a pause
            .map { [catalogue] text in
                text.isEmpty ? [] : catalogue.filter { $0.localizedStandardContains(text) }
            }
            .sink { [weak self] matches in  // the subscriber
                self?.results = matches
                self?.searchCount += 1
            }
            .store(in: &cancellables)  // keep it alive
    }
}
// </pipeline>

// <views>
struct CombineBasicsView: View {
    @StateObject private var search = SpeciesSearch()
    @State private var now = Date.now
    @State private var backgroundVisits = 0

    // A timer publisher that fires every second on the main run loop.
    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Form {
            Section("Debounced search") {
                TextField("Species", text: $search.query)
                ForEach(search.results, id: \.self) { Text($0) }
                Text("Searches run: \(search.searchCount)").foregroundStyle(.secondary)
            }
            Section("Timer and notifications") {
                Text(now, format: .dateTime.hour().minute().second())
                Text("Times sent to the background: \(backgroundVisits)")
            }
        }
        .onReceive(clock) { now = $0 }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.didEnterBackgroundNotification)
        ) { _ in backgroundVisits += 1 }
    }
}
// </views>

#Preview { CombineBasicsView() }
