import Foundation

// <reminder>
/// A local notification to schedule, described without any iOS framework so that
/// the planning rules can be tested anywhere.
public struct ReminderRequest: Hashable, Sendable {
    public var identifier: String
    public var title: String
    public var body: String
    public var fireDate: Date

    public init(identifier: String, title: String, body: String, fireDate: Date) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.fireDate = fireDate
    }
}

public struct ReminderPlanner: Sendable {
    public var schedule: WateringSchedule
    public var hour: Int                     // local time at which reminders fire

    public init(schedule: WateringSchedule = WateringSchedule(), hour: Int = 9) {
        self.schedule = schedule
        self.hour = hour
    }

    /// One reminder per plant, on its next watering day at `hour`. A plant that is
    /// already due gets a reminder at the next `hour` slot, never in the past.
    public func requests(for plants: [Plant], now: Date) -> [ReminderRequest] {
        plants.compactMap { plant -> ReminderRequest? in
            guard let dueSlot = slot(on: schedule.nextWatering(for: plant)),
                  let fireDate = dueSlot > now ? dueSlot : nextSlot(after: now)
            else { return nil }
            return ReminderRequest(
                identifier: "water-\(plant.id.uuidString)",
                title: "Time to water \(plant.nickname)",
                body: "\(plant.speciesName) in the \(plant.room.title.lowercased())",
                fireDate: fireDate)
        }
        .sorted { $0.fireDate < $1.fireDate }
    }

    private func slot(on day: Date) -> Date? {
        schedule.calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day)
    }

    private func nextSlot(after date: Date) -> Date? {
        guard let today = slot(on: date) else { return nil }
        return today > date ? today : schedule.calendar.date(byAdding: .day, value: 1, to: today)
    }
}
// </reminder>
