import SwiftUI
import UserNotifications

// <testreminder>
/// Exercise 15.1: a debug-only button that schedules a notification in 10 seconds.
struct TestReminderButton: View {
    var body: some View {
        #if DEBUG
        Button("Send a test reminder in 10 s") {
            Task {
                let center = UNUserNotificationCenter.current()
                _ = try? await center.requestAuthorization(options: [.alert, .sound])
                let content = UNMutableNotificationContent()
                content.title = "Test reminder"
                content.body = "Notifications work."
                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: 10, repeats: false)
                try? await center.add(
                    UNNotificationRequest(
                        identifier: "test", content: content, trigger: trigger))
            }
        }
        #endif
    }
}
// </testreminder>

// <countdown>
/// Exercise 15.3: a timer that no longer keeps its owner alive.
@Observable
final class CountdownModel {
    private(set) var remaining = 60
    @ObservationIgnored private var timer: Timer?

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            MainActor.assumeIsolated {  // scheduled timers fire on the main thread
                guard let self, self.remaining > 0 else {
                    timer.invalidate()
                    return
                }
                self.remaining -= 1
            }
        }
    }

    deinit { timer?.invalidate() }
}
// </countdown>

// <asyncsearch>
/// Exercise 15.4: the debounced search without Combine.
@Observable
final class AsyncSpeciesSearch {
    private(set) var results: [String] = []
    private let catalogue = [
        "Aloe", "Areca palm", "Basil", "Begonia", "Boston fern",
        "Calathea", "Monstera", "Pothos", "Snake plant", "ZZ plant",
    ]

    func search(_ query: String) async {
        try? await Task.sleep(for: .milliseconds(300))  // cancelled if the query changes
        guard !Task.isCancelled else { return }
        let text = query.trimmingCharacters(in: .whitespaces)
        results = text.isEmpty ? [] : catalogue.filter { $0.localizedStandardContains(text) }
    }
}

struct AsyncSearchView: View {
    @State private var query = ""
    @State private var search = AsyncSpeciesSearch()

    var body: some View {
        Form {
            TextField("Species", text: $query)
            ForEach(search.results, id: \.self) { Text($0) }
        }
        .task(id: query) { await search.search(query) }
    }
}
// </asyncsearch>

struct NotificationExercisesView: View {
    @State private var countdown = CountdownModel()

    var body: some View {
        VStack(spacing: 20) {
            TestReminderButton()
            Text("\(countdown.remaining) s").font(.largeTitle.monospacedDigit())
            Button("Start countdown") { countdown.start() }
            AsyncSearchView()
        }
    }
}

#Preview { NotificationExercisesView() }
