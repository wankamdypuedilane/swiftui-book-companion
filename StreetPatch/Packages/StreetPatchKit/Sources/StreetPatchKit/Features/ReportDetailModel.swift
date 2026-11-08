import Foundation
import Observation

// <detail>
/// One report: support it, or withdraw it if it is yours and still new.
@MainActor
@Observable
public final class ReportDetailModel {
    public private(set) var report: Report
    public private(set) var errorMessage: String?
    public private(set) var isWorking = false

    @ObservationIgnored private let service: any ReportsService

    public init(report: Report, service: any ReportsService) {
        self.report = report
        self.service = service
    }

    public func refresh() async {
        if let fresh = try? await service.report(id: report.id) { report = fresh }
    }

    /// Optimistic: the count changes at once and goes back if the server refuses.
    public func toggleSupport() async {
        guard report.canBeSupported, !isWorking else { return }
        let before = report
        let wanted = !report.supportedByMe
        report.supportedByMe = wanted
        report.supportCount += wanted ? 1 : -1
        isWorking = true
        defer { isWorking = false }
        do {
            let state = try await service.setSupport(wanted, for: report.id)
            report.supportCount = state.supportCount
            report.supportedByMe = state.supportedByMe
            errorMessage = nil
        } catch {
            report = before
            errorMessage = error.userMessage
        }
    }

    /// Returns true when the report is gone, so the screen can close.
    public func withdraw() async -> Bool {
        guard report.canBeWithdrawn, !isWorking else { return false }
        isWorking = true
        defer { isWorking = false }
        do {
            try await service.withdraw(id: report.id)
            return true
        } catch {
            errorMessage = error.userMessage
            if case .http(409, _) = error { await refresh() }  // the town acted meanwhile
            return false
        }
    }
}
// </detail>
