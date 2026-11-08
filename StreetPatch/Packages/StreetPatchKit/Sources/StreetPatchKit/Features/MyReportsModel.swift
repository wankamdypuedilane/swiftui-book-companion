import Foundation
import Observation

// <myreports>
/// The Mine tab: reports still on the device, then the resident's reports on the
/// server with their status.
@MainActor
@Observable
public final class MyReportsModel {
    public private(set) var pending: [PendingReport] = []
    public private(set) var reports: [Report] = []
    public private(set) var errorMessage: String?

    @ObservationIgnored private let service: any ReportsService
    @ObservationIgnored private let outbox: ReportOutbox

    public init(service: any ReportsService, outbox: ReportOutbox) {
        self.service = service
        self.outbox = outbox
    }

    /// Sends what is waiting, then reloads the list from the server.
    public func refresh() async {
        await outbox.flush()
        pending = await outbox.pending
        do {
            reports = try await service.reports(ReportFilter(mineOnly: true), page: 1).items
            errorMessage = nil
        } catch {
            errorMessage = error.userMessage
        }
    }

    public func discard(_ item: PendingReport) async {
        await outbox.discard(item.id)
        pending = await outbox.pending
    }

    public var openCount: Int { reports.count { $0.status.isOpen } }
}
// </myreports>
