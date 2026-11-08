import OSLog

/// Loggers are Sendable: `nonisolated` lets any thread use them, not only the main actor.
nonisolated enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "StreetPatch"
    static let data = Logger(subsystem: subsystem, category: "data")
    static let sync = Logger(subsystem: subsystem, category: "sync")
}
