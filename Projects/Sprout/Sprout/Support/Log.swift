import OSLog

// <log>
/// Loggers for the unified logging system. Messages appear in Xcode's console
/// and in the Console app, filtered by subsystem and category.
enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Sprout"
    static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
    static let data = Logger(subsystem: subsystem, category: "data")
}
// </log>
