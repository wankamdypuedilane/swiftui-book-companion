import Foundation
import Observation

// <reportsmodel>
/// The shared list behind the Map and List tabs: one load, two presentations.
@MainActor
@Observable
public final class ReportsModel {
    public enum Phase: Equatable { case idle, loading, loaded, failed(APIError) }

    public private(set) var reports: [Report] = []
    public private(set) var phase = Phase.idle
    public var filter = ReportFilter.open
    /// Where the resident is, when they allowed it. Sorts the list by distance.
    public var userLocation: Coordinate?

    @ObservationIgnored private let service: any ReportsService
    @ObservationIgnored private var nextPage = 1
    @ObservationIgnored private var hasMore = false

    public init(service: any ReportsService) { self.service = service }

    /// The reports in display order: nearest first when the location is known,
    /// most recently updated first otherwise.
    public var sortedReports: [Report] {
        guard let here = userLocation else { return reports }
        return reports.sorted {
            here.distance(to: $0.coordinate) < here.distance(to: $1.coordinate)
        }
    }

    public func distance(to report: Report) -> Double? {
        userLocation?.distance(to: report.coordinate)
    }

    public func reload() async {
        phase = .loading
        do {
            let page = try await service.reports(filter, page: 1)
            guard !Task.isCancelled else { return }
            reports = page.items
            hasMore = page.hasMore
            nextPage = 2
            phase = .loaded
        } catch {
            guard error != .cancelled, !Task.isCancelled else { return }
            phase = .failed(error)
        }
    }

    public func loadMoreIfNeeded(after report: Report) async {
        guard report.id == reports.last?.id, hasMore, phase == .loaded else { return }
        hasMore = false  // one request at a time
        if let page = try? await service.reports(filter, page: nextPage) {
            let known = Set(reports.map(\.id))
            reports += page.items.filter { !known.contains($0.id) }
            hasMore = page.hasMore
            nextPage += 1
        }
    }

    /// Puts a report that changed elsewhere (detail screen, outbox) into the list.
    public func upsert(_ report: Report) {
        if let index = reports.firstIndex(where: { $0.id == report.id }) {
            reports[index] = report
        } else {
            reports.insert(report, at: 0)
        }
    }

    public func remove(id: String) {
        reports.removeAll { $0.id == id }
    }
}
// </reportsmodel>
