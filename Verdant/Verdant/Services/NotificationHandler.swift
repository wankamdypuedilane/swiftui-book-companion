import UserNotifications

// <handler>
/// Receives notification events. Tapping a reminder opens the plant's detail.
final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    private let router: Router

    init(router: Router) { self.router = router }

    /// The user tapped a notification.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
        let link = response.notification.request.content.userInfo["url"] as? String
        guard let link, let url = URL(string: link) else { return }
        await router.handle(url)                       // Router lives on the main actor
    }

    /// A notification arrived while the app is in the foreground: show it anyway.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification)
        async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
// </handler>
