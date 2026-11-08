import Foundation
import Observation
import UserNotifications
import VerdantKit

// <scheduler>
/// Turns the ReminderPlanner's plan into local notifications.
@MainActor
@Observable
final class ReminderScheduler {
    enum Permission { case unknown, granted, denied }

    private(set) var permission = Permission.unknown
    private let garden: Garden
    private let isEnabled: Bool
    @ObservationIgnored private let center = UNUserNotificationCenter.current()

    init(garden: Garden, isEnabled: Bool) {
        self.garden = garden
        self.isEnabled = isEnabled
    }

    /// Asks for permission. iOS shows the system prompt only the first time.
    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [
                .alert, .sound, .badge,
            ])
            permission = granted ? .granted : .denied
        } catch {
            permission = .denied
        }
    }

    func refreshPermission() async {
        let settings = await center.notificationSettings()
        permission =
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral: .granted
            case .denied: .denied
            default: .unknown
            }
    }

    /// Replaces every pending reminder with a fresh plan for the current garden.
    func reschedule(hour: Int? = nil) async {
        guard isEnabled else { return }
        await refreshPermission()
        center.removeAllPendingNotificationRequests()
        let defaults = UserDefaults.standard
        guard permission == .granted,
            defaults.object(forKey: SettingsKey.remindersOn) as? Bool ?? true
        else { return }
        let reminderHour =
            hour ?? (defaults.object(forKey: SettingsKey.reminderHour) as? Int ?? 9)
        let plan = ReminderPlanner(hour: reminderHour).requests(for: garden.plants, now: .now)
        for reminder in plan.prefix(60) {  // iOS keeps at most 64 pending requests
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.userInfo = ["url": "verdant://plants/\(reminder.identifier.dropFirst(6))"]
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: reminder.fireDate)
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components, repeats: false)
            do {
                try await center.add(
                    UNNotificationRequest(
                        identifier: reminder.identifier,
                        content: content, trigger: trigger))
            } catch {
                Log.reminders.error(
                    "Could not schedule \(reminder.identifier, privacy: .public)")
            }
        }
        Log.reminders.info("Scheduled \(min(plan.count, 60)) reminders")
    }
}
// </scheduler>
