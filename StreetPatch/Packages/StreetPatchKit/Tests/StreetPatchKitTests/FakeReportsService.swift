import Foundation
@testable import StreetPatchKit

// <fake>
/// A ReportsService that keeps reports in memory and fails on demand. Like the real
/// server, it creates one report per idempotency key.
actor FakeReportsService: ReportsService {
    var stored: [Report] = []
    var keys: [UUID: String] = [:]
    var photos: [String: Data] = [:]
    var createCalls = 0
    /// Errors to throw, in order, before calls succeed again.
    var createFailures: [APIError] = []
    var photoFailures: [APIError] = []
    var supportFailure: APIError?
    /// Simulates a lost response: the report is created, then the call fails.
    var loseNextCreateResponse = false
    /// How long each creation takes, to let other work happen meanwhile.
    var createDelay = Duration.zero

    func failCreates(_ errors: APIError...) { createFailures = errors }
    func failPhotos(_ errors: APIError...) { photoFailures = errors }
    func failSupport(_ error: APIError?) { supportFailure = error }
    func loseNextResponse() { loseNextCreateResponse = true }
    func seed(_ reports: [Report]) { stored = reports }
    func slowCreates(_ delay: Duration) { createDelay = delay }

    func reports(_ filter: ReportFilter, page: Int) throws(APIError) -> Page<Report> {
        let items = stored.filter { !filter.mineOnly || $0.isMine }
        return Page(items: items, page: 1, totalPages: 1)
    }

    func report(id: String) throws(APIError) -> Report {
        guard let report = stored.first(where: { $0.id == id }) else {
            throw .http(status: 404, message: "Unknown report.")
        }
        return report
    }

    func create(_ draft: ReportDraft, idempotencyKey: UUID) async throws(APIError) -> Report {
        createCalls += 1
        if createDelay > .zero { try? await Task.sleep(for: createDelay) }
        if !createFailures.isEmpty { throw createFailures.removeFirst() }
        if let id = keys[idempotencyKey] { return try report(id: id) }  // a replay
        let id = String(format: "KB-%04d", stored.count + 1)
        var report = Report.sample(
            id: id, title: draft.title, category: draft.category,
            at: draft.location!, isMine: true)
        report.details = draft.details
        stored.append(report)
        keys[idempotencyKey] = id
        if loseNextCreateResponse {
            loseNextCreateResponse = false
            throw .timedOut  // created on the server, but the app never heard back
        }
        return report
    }

    func uploadPhoto(_ jpeg: Data, for id: String) throws(APIError) {
        if !photoFailures.isEmpty { throw photoFailures.removeFirst() }
        photos[id] = jpeg
    }

    func setSupport(_ supported: Bool, for id: String) throws(APIError) -> SupportState {
        if let supportFailure { throw supportFailure }
        guard let index = stored.firstIndex(where: { $0.id == id }) else {
            throw .http(status: 404, message: nil)
        }
        if stored[index].supportedByMe != supported {
            stored[index].supportCount += supported ? 1 : -1
            stored[index].supportedByMe = supported
        }
        return SupportState(
            supportCount: stored[index].supportCount, supportedByMe: supported)
    }

    func withdraw(id: String) throws(APIError) {
        guard let report = stored.first(where: { $0.id == id }) else {
            throw .http(status: 404, message: nil)
        }
        guard report.status == .submitted else {
            throw .http(status: 409, message: "Already acknowledged.")
        }
        stored.removeAll { $0.id == id }
    }
}
// </fake>

let square = Coordinate(latitude: 48.3901, longitude: -4.4850)
let validDraft = ReportDraft(
    title: "Broken bench in the square", category: .other, location: square)
