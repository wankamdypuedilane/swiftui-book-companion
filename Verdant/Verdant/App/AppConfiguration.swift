import Foundation

/// Build-time configuration, delivered by the .xcconfig files through Info.plist.
enum AppConfiguration {
    static let apiBaseURL: URL = {
        guard
            let text = Bundle.main.object(forInfoDictionaryKey: "VerdantAPIBaseURL") as? String,
            let url = URL(string: text)
        else {
            fatalError(
                "VerdantAPIBaseURL is missing from Info.plist: check the .xcconfig files")
        }
        return url
    }()
}
