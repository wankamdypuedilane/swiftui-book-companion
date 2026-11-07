import Foundation
import Testing
@testable import StreetPatchKit

// <featuretests>
@MainActor
@Suite("View models")
struct FeatureModelTests {
    let service = FakeReportsService()

    @Test func composerShowsProblemsOnlyAfterTheFirstAttempt() async {
        let composer = ComposerModel(
            outbox: ReportOutbox(storage: InMemoryOutboxStorage(), service: service))
        #expect(composer.problems.isEmpty)
        #expect(await composer.submit() == nil)
        #expect(composer.problems == [.titleTooShort, .noLocation])
        #expect(await service.createCalls == 0)  // nothing left the device
    }

    @Test func composerSendsAndResetsButKeepsThePlace() async throws {
        let composer = ComposerModel(
            outbox: ReportOutbox(storage: InMemoryOutboxStorage(), service: service),
            location: square)
        composer.draft.title = validDraft.title
        composer.draft.category = .litter
        let outcome = try #require(await composer.submit())
        guard case .sent(let report) = outcome else {
            Issue.record("expected .sent, got \(outcome)")
            return
        }
        #expect(report.category == .litter)
        #expect(composer.draft.title.isEmpty)
        #expect(composer.draft.location == square && composer.draft.category == .litter)
    }

    @Test func composerQueuesWhenOffline() async {
        await service.failCreates(.offline)
        let storage = InMemoryOutboxStorage()
        let composer = ComposerModel(
            outbox: ReportOutbox(storage: storage, service: service), location: square)
        composer.draft.title = validDraft.title
        #expect(await composer.submit() == .queued)
        #expect(await storage.load().count == 1)
    }

    @Test func composerKeepsTheDraftWhenRefused() async {
        await service.failCreates(.http(status: 422, message: "Unknown category."))
        let storage = InMemoryOutboxStorage()
        let composer = ComposerModel(
            outbox: ReportOutbox(storage: storage, service: service), location: square)
        composer.draft.title = validDraft.title
        #expect(await composer.submit() == .refused("Unknown category."))
        #expect(composer.draft.title == validDraft.title)
        #expect(await storage.load().isEmpty)  // not left behind in the outbox
    }

    @Test func supportIsOptimisticAndRolledBack() async {
        let report = Report.sample(supportCount: 3)
        await service.seed([report])
        let detail = ReportDetailModel(report: report, service: service)
        await detail.toggleSupport()
        #expect(detail.report.supportCount == 4 && detail.report.supportedByMe)

        await service.failSupport(.offline)
        await detail.toggleSupport()
        #expect(detail.report.supportCount == 4)  // back to the value before the tap
        #expect(detail.errorMessage == APIError.offline.userMessage)
    }

    @Test func withdrawingAnAcknowledgedReportRefreshesIt() async {
        let mine = Report.sample(isMine: true)
        await service.seed([Report.sample(status: .acknowledged, isMine: true)])
        let detail = ReportDetailModel(report: mine, service: service)
        #expect(await detail.withdraw() == false)
        #expect(detail.report.status == .acknowledged)  // shows what the town did
    }

    @Test func listSortsByDistanceOnceTheLocationIsKnown() async {
        let near = Report.sample(id: "KB-0001", at: square)
        let far = Report.sample(
            id: "KB-0002", at: Coordinate(latitude: 48.41, longitude: -4.45))
        await service.seed([far, near])
        let model = ReportsModel(service: service)
        await model.reload()
        #expect(model.sortedReports.map(\.id) == ["KB-0002", "KB-0001"])
        model.userLocation = square
        #expect(model.sortedReports.map(\.id) == ["KB-0001", "KB-0002"])
    }
}
// </featuretests>
