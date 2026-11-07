import SwiftUI

// <dates>
struct DatesView: View {
    @State private var sowingDate = Date.now
    @State private var reminderTime = Date.now
    @State private var harvestDays = 60

    private var harvestDate: Date {
        Calendar.current.date(byAdding: .day, value: harvestDays, to: sowingDate) ?? sowingDate
    }

    var body: some View {
        Form {
            Section("Pickers") {
                DatePicker(
                    "Sown on", selection: $sowingDate, in: ...Date.now,
                    displayedComponents: .date)  // no future dates
                DatePicker(
                    "Reminder", selection: $reminderTime, displayedComponents: .hourAndMinute)
                Stepper(
                    "Harvest after \(harvestDays) days", value: $harvestDays, in: 7...200,
                    step: 7)
            }
            Section("Computed with Calendar") {
                LabeledContent(
                    "Harvest", value: harvestDate, format: .dateTime.day().month().year())
                LabeledContent(
                    "Weekday", value: harvestDate.formatted(.dateTime.weekday(.wide)))
                LabeledContent("Days from now") {
                    Text(harvestDate, style: .relative)
                }
            }
            Section("The same date, formatted") {
                Text(sowingDate.formatted(date: .abbreviated, time: .omitted))
                Text(sowingDate.formatted(date: .complete, time: .shortened))
                Text(sowingDate.formatted(.iso8601))  // for machines only
                Text(sowingDate, format: .dateTime.month(.wide).year())
            }
            Section("Graphical calendar") {
                DatePicker(
                    "Sown on", selection: $sowingDate, in: ...Date.now,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
        }
    }
}
// </dates>

#Preview { DatesView() }
