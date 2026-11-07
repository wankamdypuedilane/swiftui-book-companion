import Foundation
@testable import VerdantKit

/// A Gregorian calendar in UTC, so that tests give the same result everywhere.
let utc: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
    return calendar
}()

/// 2026-11-01 08:00 UTC, the "today" of most tests.
let reference = Date(timeIntervalSince1970: 1_793_520_000)

func day(_ offset: Int, from date: Date = reference) -> Date {
    utc.date(byAdding: .day, value: offset, to: date) ?? date
}

func makePlant(_ name: String, interval: Int, lastWatered: Int? = nil, acquired: Int = -100,
               room: Room = .livingRoom, favorite: Bool = false) -> Plant {
    let log = lastWatered.map { [CareEvent(kind: .watered, date: day($0))] } ?? []
    return Plant(nickname: name, speciesName: "Test species", room: room,
                 wateringIntervalDays: interval, acquiredOn: day(acquired),
                 careLog: log, isFavorite: favorite)
}
