import CoreLocation
import Observation

// <location>
/// The user's location, with the modern Core Location API (iOS 18):
/// a service session requests "when in use" authorization, and live updates
/// arrive as an asynchronous sequence. No delegate is needed.
@MainActor
@Observable
final class LocationService {
    enum Status: Equatable { case idle, locating, located, denied, unavailable }

    private(set) var status = Status.idle
    private(set) var location: CLLocation?
    @ObservationIgnored private var session: CLServiceSession?

    /// Finds the user's position once, then stops.
    func locateOnce() async {
        status = .locating
        session = CLServiceSession(authorization: .whenInUse)    // may show the system prompt
        defer { session = nil }                                   // release the session
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                if update.authorizationDenied || update.authorizationDeniedGlobally {
                    status = .denied
                    return
                }
                if let location = update.location, location.horizontalAccuracy < 500 {
                    self.location = location
                    status = .located
                    return                                        // leaving the loop stops updates
                }
            }
        } catch {
            status = .unavailable
        }
    }
}
// </location>
