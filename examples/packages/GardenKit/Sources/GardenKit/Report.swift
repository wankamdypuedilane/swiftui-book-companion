/// Formats the plans of a garden. `package` would make it visible to every
/// module of this package; `public` makes it visible to every client.
public func report(for plans: [WateringPlan], today: Int) -> String {
    plans.sorted { $0.nextWatering(today: today) < $1.nextWatering(today: today) }
        .map { "\($0.plantName): day \($0.nextWatering(today: today)) (\($0.history.count) waterings)" }
        .joined(separator: "\n")
}
