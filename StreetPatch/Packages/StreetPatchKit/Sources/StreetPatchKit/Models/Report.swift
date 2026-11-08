import Foundation

// <report>
/// A report as the API returns it. The author is never sent: only whether the
/// signed-in user wrote it.
public struct Report: Codable, Identifiable, Hashable, Sendable {
    public struct Change: Codable, Hashable, Sendable {
        public var status: ReportStatus
        public var at: Date
        public var note: String?
    }

    public var id: String
    public var title: String
    public var details: String
    public var category: ReportCategory
    public var status: ReportStatus
    public var latitude: Double
    public var longitude: Double
    public var createdAt: Date
    public var updatedAt: Date
    public var supportCount: Int
    public var supportedByMe: Bool
    public var isMine: Bool
    public var hasPhoto: Bool
    public var history: [Change]

    public var coordinate: Coordinate { Coordinate(latitude: latitude, longitude: longitude) }

    /// The author may withdraw a report until the town acknowledges it.
    public var canBeWithdrawn: Bool { isMine && status == .submitted }

    /// Residents support other people's reports, not their own.
    public var canBeSupported: Bool { !isMine && status.isOpen }
}

/// One page of a paginated list, as sent by the API.
public struct Page<Item: Codable & Sendable>: Codable, Sendable {
    public var items: [Item]
    public var page: Int
    public var totalPages: Int

    public var hasMore: Bool { page < totalPages }
}
// </report>

extension Report {
    /// A report for previews and tests.
    public static func sample(
        id: String = "KB-0001", title: String = "Deep pothole at the bus stop",
        category: ReportCategory = .pothole, status: ReportStatus = .submitted,
        at coordinate: Coordinate = ServiceArea.kerbrume.centre, isMine: Bool = false,
        supportCount: Int = 0, date: Date = Date(timeIntervalSince1970: 1_793_000_000)
    ) -> Report {
        Report(
            id: id, title: title, details: "", category: category, status: status,
            latitude: coordinate.latitude, longitude: coordinate.longitude,
            createdAt: date, updatedAt: date, supportCount: supportCount,
            supportedByMe: false, isMine: isMine, hasPhoto: false,
            history: [Change(status: .submitted, at: date, note: nil)])
    }
}
