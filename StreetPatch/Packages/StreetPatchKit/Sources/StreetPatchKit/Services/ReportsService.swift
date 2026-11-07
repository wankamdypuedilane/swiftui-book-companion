import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// <service>
/// Which reports a list shows.
public struct ReportFilter: Equatable, Sendable {
    public var statuses: Set<ReportStatus>
    public var category: ReportCategory?
    public var mineOnly: Bool
    public var near: Coordinate?
    public var radius: Double  // metres, used with near

    public init(
        statuses: Set<ReportStatus> = [], category: ReportCategory? = nil,
        mineOnly: Bool = false, near: Coordinate? = nil, radius: Double = 1000
    ) {
        self.statuses = statuses
        self.category = category
        self.mineOnly = mineOnly
        self.near = near
        self.radius = radius
    }

    public static let open = ReportFilter(statuses: [.submitted, .acknowledged, .inProgress])

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if !statuses.isEmpty {
            let list = statuses.map(\.rawValue).sorted().joined(separator: ",")
            items.append(URLQueryItem(name: "status", value: list))
        }
        if let category {
            items.append(URLQueryItem(name: "category", value: category.rawValue))
        }
        if mineOnly { items.append(URLQueryItem(name: "mine", value: "true")) }
        if let near {
            items.append(
                URLQueryItem(name: "near", value: "\(near.latitude),\(near.longitude)"))
            items.append(URLQueryItem(name: "radius", value: String(Int(radius))))
        }
        return items
    }
}

public struct SupportState: Codable, Equatable, Sendable {
    public var supportCount: Int
    public var supportedByMe: Bool
}

/// Everything the app asks of the StreetPatch API about reports. View models depend
/// on this protocol; tests and previews give them a fake.
public protocol ReportsService: Sendable {
    func reports(_ filter: ReportFilter, page: Int) async throws(APIError) -> Page<Report>
    func report(id: String) async throws(APIError) -> Report
    func create(_ draft: ReportDraft, idempotencyKey: UUID) async throws(APIError) -> Report
    func uploadPhoto(_ jpeg: Data, for id: String) async throws(APIError)
    func setSupport(_ supported: Bool, for id: String) async throws(APIError) -> SupportState
    func withdraw(id: String) async throws(APIError)
}
// </service>

// <remote>
public struct RemoteReportsService: ReportsService {
    private let client: APIClient

    public init(client: APIClient) { self.client = client }

    public func reports(
        _ filter: ReportFilter, page: Int
    ) async throws(APIError) -> Page<Report> {
        let query = filter.queryItems + [URLQueryItem(name: "page", value: String(page))]
        return try await client.send(
            Endpoint<Page<Report>>(
                .get, "reports", query: query, requiresAuthentication: filter.mineOnly))
    }

    public func report(id: String) async throws(APIError) -> Report {
        try await client.send(Endpoint<Report>(.get, "reports/\(id)"))
    }

    private struct NewReport: Encodable {
        let title, details: String
        let category: ReportCategory
        let latitude, longitude: Double
    }

    public func create(
        _ draft: ReportDraft, idempotencyKey: UUID
    ) async throws(APIError) -> Report {
        guard let location = draft.location else { throw .invalidRequest("No location") }
        let payload = NewReport(
            title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
            details: draft.details, category: draft.category,
            latitude: location.latitude, longitude: location.longitude)
        let body: Data
        do { body = try APIClient.makeEncoder().encode(payload) } catch {
            throw .invalidRequest("Could not encode the report")
        }
        // The key makes the request safe to repeat: the server answers a replay with
        // the report it already created instead of creating a second one.
        return try await client.send(
            Endpoint<Report>(
                .post, "reports", body: body,
                headers: ["Idempotency-Key": idempotencyKey.uuidString],
                requiresAuthentication: true))
    }

    public func uploadPhoto(_ jpeg: Data, for id: String) async throws(APIError) {
        _ = try await client.send(
            Endpoint<NoContent>(
                .put, "reports/\(id)/photo", body: jpeg, contentType: "image/jpeg",
                requiresAuthentication: true))
    }

    public func setSupport(
        _ supported: Bool, for id: String
    ) async throws(APIError) -> SupportState {
        try await client.send(
            Endpoint<SupportState>(
                supported ? .put : .delete, "reports/\(id)/support",
                requiresAuthentication: true))
    }

    public func withdraw(id: String) async throws(APIError) {
        _ = try await client.send(
            Endpoint<NoContent>(.delete, "reports/\(id)", requiresAuthentication: true))
    }
}
// </remote>
