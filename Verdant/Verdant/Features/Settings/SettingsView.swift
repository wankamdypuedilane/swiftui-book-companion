import SwiftUI
import VerdantKit

// <settings>
struct SettingsView: View {
    @AppStorage(SettingsKey.hasCompletedOnboarding) private var hasCompletedOnboarding = true
    @AppStorage(SettingsKey.remindersOn) private var remindersOn = true
    @AppStorage(SettingsKey.reminderHour) private var reminderHour = 9
    @Environment(ReminderScheduler.self) private var reminders
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Watering reminders", isOn: $remindersOn)
                    if remindersOn {
                        Picker("Remind me at", selection: $reminderHour) {
                            ForEach([7, 8, 9, 12, 18, 20], id: \.self) { hour in
                                Text(hourText(hour)).tag(hour)
                            }
                        }
                        if reminders.permission == .denied {
                            Button("Allow notifications in Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    openURL(url)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Verdant schedules one reminder per plant, on the day it needs water.")
                }
                AccountSection()
                Section("About") {
                    Button("Show the introduction again") { hasCompletedOnboarding = false }
                    LabeledContent("Version", value: Bundle.main.versionString)
                }
            }
            .navigationTitle("Settings")
            .task(id: remindersOn) {
                if remindersOn && reminders.permission == .unknown { await reminders.requestPermission() }
                await reminders.reschedule()
            }
            .onChange(of: reminderHour) { _, hour in
                Task { await reminders.reschedule(hour: hour) }
            }
        }
    }

    private func hourText(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }
}

extension Bundle {
    var versionString: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(version) (\(build))"
    }
}
// </settings>
