import Foundation
import Testing
@testable import StreetPatchKit

// Solution to Exercise 25.3. In the app it would live in Models/ReportDraft.swift.
// <duplicates>
extension ReportDraft {
    /// Open reports of the same category within `radius` metres, nearest first.
    func possibleDuplicates(in reports: [Report], radius: Double = 30) -> [Report] {
        guard let location else { return [] }
        return
            reports
            .filter { $0.category == category && $0.status.isOpen }
            .map { ($0, location.distance(to: $0.coordinate)) }
            .filter { $0.1 <= radius }
            .sorted { $0.1 < $1.1 }
            .map(\.0)
    }
}
// </duplicates>

@Suite("Exercise 25.3")
struct DuplicateTests {
    /// A point `metres` north of the square.
    func north(_ metres: Double) -> Coordinate {
        Coordinate(latitude: square.latitude + metres / 111_195, longitude: square.longitude)
    }

    @Test func findsOpenReportsOfTheSameCategoryNearby() {
        let draft = ReportDraft(title: "Hole", category: .pothole, location: square)
        let reports = [
            Report.sample(id: "far", category: .pothole, at: north(50)),
            Report.sample(id: "near", category: .pothole, at: north(10)),
            Report.sample(id: "nearer", category: .pothole, at: north(5)),
            Report.sample(id: "other", category: .litter, at: north(5)),
            Report.sample(id: "closed", category: .pothole, status: .resolved, at: north(5)),
        ]
        #expect(draft.possibleDuplicates(in: reports).map(\.id) == ["nearer", "near"])
    }

    @Test func noLocationNoDuplicates() {
        #expect(ReportDraft().possibleDuplicates(in: [Report.sample()]).isEmpty)
    }
}
