import Foundation

// <config>
/// Values that differ between Debug and Release builds. They come from the
/// .xcconfig files, through Info.plist, into the running app.
struct AppConfiguration {
    let apiBaseURL: URL
    let environmentName: String

    static let current: AppConfiguration = {
        let info = Bundle.main.infoDictionary ?? [:]
        guard let text = info["APIBaseURL"] as? String, let url = URL(string: text) else {
            fatalError("APIBaseURL is missing from Info.plist: check the .xcconfig files")
        }
        let name = info["SproutEnvironmentName"] as? String ?? "Unknown"
        return AppConfiguration(apiBaseURL: url, environmentName: name)
    }()
}
// </config>
