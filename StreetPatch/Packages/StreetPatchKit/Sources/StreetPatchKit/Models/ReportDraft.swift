import Foundation

// <draft>
/// What the resident is writing, before it is sent. Validation runs here, on the
/// device, with the same limits as the server, so most mistakes never cost a request.
public struct ReportDraft: Codable, Equatable, Sendable {
    public enum Problem: Equatable, Sendable {
        case titleTooShort, titleTooLong, detailsTooLong, noLocation, outsideArea
    }

    public var title = ""
    public var details = ""
    public var category = ReportCategory.pothole
    public var location: Coordinate?

    public init(
        title: String = "", details: String = "", category: ReportCategory = .pothole,
        location: Coordinate? = nil
    ) {
        self.title = title
        self.details = details
        self.category = category
        self.location = location
    }

    public static let titleLength = 5...80
    public static let maxDetailsLength = 1000

    public func problems(in area: ServiceArea = .kerbrume) -> [Problem] {
        var problems: [Problem] = []
        let length = title.trimmingCharacters(in: .whitespacesAndNewlines).count
        if length < Self.titleLength.lowerBound { problems.append(.titleTooShort) }
        if length > Self.titleLength.upperBound { problems.append(.titleTooLong) }
        if details.count > Self.maxDetailsLength { problems.append(.detailsTooLong) }
        if let location {
            if !area.contains(location) { problems.append(.outsideArea) }
        } else {
            problems.append(.noLocation)
        }
        return problems
    }

    public var isValid: Bool { problems().isEmpty }
}

extension ReportDraft.Problem {
    public var message: String {
        switch self {
        case .titleTooShort: "Describe the problem in at least 5 characters."
        case .titleTooLong: "Keep the title under 80 characters."
        case .detailsTooLong: "The details are limited to 1,000 characters."
        case .noLocation: "Choose where the problem is."
        case .outsideArea: "This place is outside Kerbrume."
        }
    }
}
// </draft>
