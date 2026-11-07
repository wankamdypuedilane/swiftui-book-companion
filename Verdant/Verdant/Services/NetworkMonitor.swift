import Network
import Observation

// <monitor>
/// Whether the device currently has a network path, for the offline banner.
@MainActor
@Observable
final class NetworkMonitor {
    private(set) var isConnected = true
    @ObservationIgnored private var task: Task<Void, Never>?

    func start() {
        guard task == nil else { return }
        task = Task { [weak self] in
            for await path in NWPathMonitor() {  // an AsyncSequence since iOS 17
                self?.isConnected = path.status == .satisfied
            }
        }
    }

    deinit { task?.cancel() }
}
// </monitor>
