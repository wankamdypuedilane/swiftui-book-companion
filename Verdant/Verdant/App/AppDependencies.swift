import Foundation
import SwiftData
import UserNotifications
import VerdantKit

// <dependencies>
/// The composition root: the one place that creates the app's objects and wires
/// them together. Everything else receives what it needs.
@MainActor
final class AppDependencies {
    let garden: Garden
    let catalog: CatalogModel
    let places: PlacesModel
    let account: AccountModel
    let reminders: ReminderScheduler
    let network: NetworkMonitor
    let router: Router
    private let notificationHandler: NotificationHandler

    init(
        store: any PlantStore, tokenStore: any TokenStore, apiBaseURL: URL,
        remindersEnabled: Bool
    ) {
        garden = Garden(store: store)

        // Unauthenticated client for sign-in and refresh, authenticated client for the rest.
        let configuration = APIConfiguration(baseURL: apiBaseURL)
        let publicClient = APIClient(configuration: configuration)
        let auth = AuthService(client: publicClient)
        let authenticator = Authenticator(store: tokenStore) { refreshToken in
            try await auth.refresh(refreshToken: refreshToken)
        }
        let client = APIClient(configuration: configuration, authenticator: authenticator)

        let cache: any SpeciesCache =
            (try? FileSpeciesCache(folder: FileSpeciesCache.defaultFolder()))
            ?? MemorySpeciesCache()
        catalog = CatalogModel(
            repository: SpeciesRepository(
                service: RemoteSpeciesService(client: client), cache: cache))
        places = PlacesModel(service: RemotePlacesService(client: client))
        account = AccountModel(
            auth: auth, authenticator: authenticator,
            backup: RemoteBackupService(client: client), garden: garden)
        reminders = ReminderScheduler(garden: garden, isEnabled: remindersEnabled)
        network = NetworkMonitor()
        router = Router()
        notificationHandler = NotificationHandler(router: router)
    }

    /// Loads the saved data once the first window appears.
    func start() async {
        UNUserNotificationCenter.current().delegate = notificationHandler
        network.start()
        await garden.load()
        await account.restore()
        await reminders.reschedule()
    }

    /// Chooses real or test dependencies from the launch arguments.
    static func makeForLaunch() -> AppDependencies {
        let arguments = ProcessInfo.processInfo.arguments
        let baseURL = AppConfiguration.apiBaseURL
        if arguments.contains("-uiTesting") {
            if arguments.contains("-showOnboarding") {
                // A stored value, not an argument: the app can then change it.
                UserDefaults.standard.set(false, forKey: SettingsKey.hasCompletedOnboarding)
            }
            // UI tests: sample data in memory, no keychain, no notifications.
            return AppDependencies(
                store: InMemoryPlantStore(plants: SampleData.garden()),
                tokenStore: InMemoryTokenStore(), apiBaseURL: baseURL,
                remindersEnabled: false)
        }
        return AppDependencies(
            store: Self.makeSwiftDataStore(),
            tokenStore: KeychainTokenStore(service: "verdant.session"),
            apiBaseURL: baseURL, remindersEnabled: true)
    }

    private static func makeSwiftDataStore() -> any PlantStore {
        do {
            let container = try ModelContainer(for: PlantRecord.self, CareEventRecord.self)
            return SwiftDataPlantStore(modelContainer: container)
        } catch {
            // The database could not be opened: keep the app usable with a JSON file.
            Log.data.error(
                "SwiftData unavailable: \(error.localizedDescription, privacy: .public)")
            let url =
                (try? JSONFilePlantStore.defaultURL())
                ?? FileManager.default.temporaryDirectory.appendingPathComponent("garden.json")
            return JSONFilePlantStore(fileURL: url)
        }
    }

    /// For SwiftUI previews: sample data, nothing saved.
    static let preview = AppDependencies(
        store: InMemoryPlantStore(plants: SampleData.garden()),
        tokenStore: InMemoryTokenStore(),
        apiBaseURL: AppConfiguration.apiBaseURL,
        remindersEnabled: false)
}
// </dependencies>
