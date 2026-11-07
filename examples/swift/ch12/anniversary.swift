// Exercise 12.2: days until the next anniversary of a date.
import Foundation

// <anniversary>
func daysUntilNextAnniversary(of date: Date, from today: Date, calendar: Calendar) -> Int {
    let components = calendar.dateComponents([.month, .day], from: date)
    let start = calendar.startOfDay(for: today)
    // Searching from one second before today's start lets today itself match.
    guard
        let next = calendar.nextDate(
            after: start.addingTimeInterval(-1), matching: components,
            matchingPolicy: .nextTimePreservingSmallerComponents)
    else { return 0 }
    return calendar.dateComponents([.day], from: start, to: next).day ?? 0
}
// </anniversary>

let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Europe/Paris")!
    return calendar
}()
func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
    calendar.date(from: DateComponents(year: y, month: m, day: d, hour: 15))!
}

let today = day(2026, 11, 7)
for (label, date) in [
    ("Adopted 2025-11-07", day(2025, 11, 7)),
    ("Adopted 2024-11-08", day(2024, 11, 8)),
    ("Adopted 2025-03-30", day(2025, 3, 30)),
    ("Adopted 2024-02-29", day(2024, 2, 29)),
] {
    let days = daysUntilNextAnniversary(of: date, from: today, calendar: calendar)
    print(label, "->", days, days == 1 ? "day" : "days")
}
