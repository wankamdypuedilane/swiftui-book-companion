import OSLog

/// Loggers are Sendable: `nonisolated` lets any thread use them, not only the main actor.
nonisolated enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Verdant"
    static let data = Logger(subsystem: subsystem, category: "data")
    static let network = Logger(subsystem: subsystem, category: "network")
    static let reminders = Logger(subsystem: subsystem, category: "reminders")
}
