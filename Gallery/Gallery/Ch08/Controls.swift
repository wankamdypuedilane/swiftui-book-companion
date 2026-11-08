import SwiftUI

// <controls>
struct ControlsView: View {
    enum Light: String, CaseIterable, Identifiable {
        case low, medium, bright
        var id: Self { self }
    }

    @State private var remindersOn = true
    @State private var intervalDays = 7
    @State private var potSize = 14.0
    @State private var light = Light.medium

    var body: some View {
        Form {
            Toggle("Watering reminders", isOn: $remindersOn)
            Stepper("Every \(intervalDays) days", value: $intervalDays, in: 1...60)
            VStack(alignment: .leading) {
                Text("Pot diameter: \(Int(potSize)) cm")
                Slider(value: $potSize, in: 6...40, step: 1)
            }
            Picker("Light", selection: $light) {
                ForEach(Light.allCases) { level in
                    Text(level.rawValue.capitalized).tag(level)
                }
            }
            .pickerStyle(.segmented)
            Section("Summary") {
                Text(remindersOn ? "Reminder every \(intervalDays) days" : "No reminders")
                Text("\(Int(potSize)) cm pot, \(light.rawValue) light")
            }
        }
    }
}
// </controls>

#Preview { ControlsView() }
