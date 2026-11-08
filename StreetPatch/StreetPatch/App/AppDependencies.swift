import Foundation
import StreetPatchKit

// <dependencies>
/// The composition root: the only place that decides which implementations the
/// app uses. Views receive the models through the environment.
@Observable
final class AppDependencies {
    let reports: ReportsModel
    let session: SessionModel
    let mine: MyReportsModel
    let network = NetworkMonitor()
    let location = LocationService()
    let service: any ReportsService
    let outbox: ReportOutbox
    let photoURL: (Report) -> URL
    /// False in UI tests: the location prompt would cover the screens under test.
    let usesLocation: Bool

    init(
        tokenStore: any TokenStore, outboxStorage: any OutboxStorage, apiBaseURL: URL,
        usesLocation: Bool = true
    ) {
        self.usesLocation = usesLocation
        let configuration = APIConfiguration(baseURL: apiBaseURL)
        let publicClient = APIClient(configuration: configuration)
        let auth = AuthService(client: publicClient)
        let authenticator = Authenticator(store: tokenStore) { refreshToken in
            try await auth.refresh(refreshToken: refreshToken)
        }
        let client = APIClient(configuration: configuration, authenticator: authenticator)
        let service = RemoteReportsService(client: client)
        self.service = service
        outbox = ReportOutbox(storage: outboxStorage, service: service)
        reports = ReportsModel(service: service)
        session = SessionModel(auth: auth, authenticator: authenticator)
        mine = MyReportsModel(service: service, outbox: outbox)
        photoURL = { apiBaseURL.appendingPathComponent("reports/\($0.id)/photo") }
    }

    func makeComposer() -> ComposerModel {
        ComposerModel(
            outbox: outbox,
            location: location.location.map {
                Coordinate(
                    latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            } ?? ServiceArea.kerbrume.centre)
    }

    func makeDetail(for report: Report) -> ReportDetailModel {
        ReportDetailModel(report: report, service: service)
    }

    /// Chooses real or test dependencies from the launch arguments.
    static func makeForLaunch() -> AppDependencies {
        if ProcessInfo.processInfo.arguments.contains("-uiTesting") {
            // UI tests: the live local API, but no Keychain and a fresh outbox.
            return AppDependencies(
                tokenStore: InMemoryTokenStore(), outboxStorage: InMemoryOutboxStorage(),
                apiBaseURL: AppConfiguration.apiBaseURL, usesLocation: false)
        }
        let outboxURL =
            (try? JSONFileOutboxStorage.defaultURL())
            ?? URL.temporaryDirectory.appendingPathComponent("outbox.json")
        return AppDependencies(
            tokenStore: KeychainTokenStore(service: "streetpatch.session"),
            outboxStorage: JSONFileOutboxStorage(url: outboxURL),
            apiBaseURL: AppConfiguration.apiBaseURL)
    }
}
// </dependencies>
