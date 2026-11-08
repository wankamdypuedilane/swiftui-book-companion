import Foundation
import Testing
@testable import StreetPatchKit

// <modeltests>
@Suite("Report rules")
struct ReportRuleTests {
    @Test(arguments: [
        (ReportStatus.submitted, ReportStatus.acknowledged, true),
        (.submitted, .rejected, true),
        (.submitted, .resolved, false),  // no skipping ahead
        (.acknowledged, .inProgress, true),
        (.inProgress, .resolved, true),
        (.inProgress, .rejected, false),  // work has started
        (.resolved, .submitted, false),  // final
    ])
    func statusTransitions(from: ReportStatus, to: ReportStatus, allowed: Bool) {
        #expect(from.canMove(to: to) == allowed)
    }

    @Test func onlyResolvedAndRejectedAreClosed() {
        #expect(ReportStatus.allCases.filter { !$0.isOpen } == [.resolved, .rejected])
    }

    @Test func unknownCategoryDecodesAsOther() throws {
        let decoded = try JSONDecoder().decode(
            [ReportCategory].self, from: Data(#"["drain","bench"]"#.utf8))
        #expect(decoded == [.drain, .other])
    }

    @Test func withdrawingAndSupportingDependOnAuthorAndStatus() {
        #expect(Report.sample(isMine: true).canBeWithdrawn)
        #expect(!Report.sample(status: .acknowledged, isMine: true).canBeWithdrawn)
        #expect(!Report.sample(isMine: true).canBeSupported)
        #expect(Report.sample(isMine: false).canBeSupported)
        #expect(!Report.sample(status: .resolved).canBeSupported)
    }
}

@Suite("Places and drafts")
struct DraftTests {
    @Test func distanceBetweenTwoKnownPoints() {
        // 0.01 degree of latitude is about 1,112 metres everywhere on Earth.
        let north = Coordinate(latitude: square.latitude + 0.01, longitude: square.longitude)
        #expect(abs(square.distance(to: north) - 1112) < 2)
        #expect(square.distance(to: square) == 0)
    }

    @Test func serviceAreaContainsTheTownOnly() {
        #expect(ServiceArea.kerbrume.contains(square))
        #expect(!ServiceArea.kerbrume.contains(Coordinate(latitude: 48.0, longitude: -4.48)))
    }

    @Test func emptyDraftHasTwoProblems() {
        #expect(ReportDraft().problems() == [.titleTooShort, .noLocation])
    }

    @Test func titleIsTrimmedBeforeCounting() {
        let draft = ReportDraft(title: "   Crack   ", location: square)
        #expect(draft.isValid)
        #expect(ReportDraft(title: "  ab  ", location: square).problems() == [.titleTooShort])
    }

    @Test func limitsMatchTheServer() {
        var draft = validDraft
        draft.title = String(repeating: "x", count: 81)
        draft.details = String(repeating: "y", count: 1001)
        draft.location = Coordinate(latitude: 48.5, longitude: -4.48)
        #expect(draft.problems() == [.titleTooLong, .detailsTooLong, .outsideArea])
    }
}

@Suite("Photos and filters")
struct PhotoAndFilterTests {
    @Test func largePhotosAreScaledKeepingTheirShape() {
        let size = PhotoPolicy.standard.targetSize(width: 4032, height: 3024)
        #expect(size.width == 2048 && size.height == 1536)
        let small = PhotoPolicy.standard.targetSize(width: 800, height: 600)
        #expect(small.width == 800 && small.height == 600)
    }

    @Test func compressionStopsAtTheFirstQualityThatFits() {
        var tried: [Double] = []
        let data = PhotoPolicy.standard.compress { quality in
            tried.append(quality)
            return Data(count: quality > 0.5 ? 3_000_000 : 1_500_000)
        }
        #expect(tried == [0.8, 0.6, 0.4])
        #expect(data?.count == 1_500_000)
    }

    @Test func filterBecomesQueryItems() {
        let filter = ReportFilter(
            statuses: [.submitted, .acknowledged], category: .drain, mineOnly: true,
            near: square, radius: 250)
        let items = Dictionary(
            uniqueKeysWithValues: filter.queryItems.map { ($0.name, $0.value ?? "") })
        #expect(items["status"] == "acknowledged,submitted")  // sorted: stable URLs
        #expect(items["category"] == "drain")
        #expect(items["mine"] == "true")
        #expect(items["near"] == "48.3901,-4.485")
        #expect(items["radius"] == "250")
    }
}
// </modeltests>
