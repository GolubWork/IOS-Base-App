import UIKit
import AppsFlyerLib
import AppTrackingTransparency
import FirebaseCore
import FirebaseMessaging
import UserNotifications

/// Application delegate responsible for configuring Firebase, AppsFlyer,
/// push notifications, and handling application lifecycle events.
/// Holds the dependency container created at launch; BaseProject reads it and passes into the view hierarchy.
final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    /// Current orientation lock used to restrict supported interface orientations.
    var orientationLock: UIInterfaceOrientationMask = .portrait

    /// Dependency container created at launch. Set in didFinishLaunching; BaseProject reads it and injects into views.
    private(set) var container: DependencyContainer!
    private var hasStartedAppsFlyer = false


    /// Performs application startup configuration including Firebase setup,
    /// push notification registration, and AppsFlyer initialization.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        container = AppDependencies.containerForTesting ?? AppDependencies.makeDefaultContainer()
        AppDependencies.setLaunchContainer(container)

        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()

        guard let container = self.container else { return true }
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = container.configuration.appsFlyerDevKey
        appsFlyer.appleAppID = container.configuration.storeIdWithPrefix
        appsFlyer.delegate = container.analyticsRepository as? AppsFlyerLibDelegate
        appsFlyer.isDebug = container.configuration.isDebug

        return true
    }

    /// Notifies AppsFlyer when the application becomes active; requests ATT only when status is not yet determined (system shows the prompt once).
    func applicationDidBecomeActive(_ application: UIApplication) {
        triggerTrackingAuthorizationFlowIfNeeded()
    }

    /// Public bridge for SwiftUI scene lifecycle to ensure the ATT/startup flow runs on app launch in scene-based environments.
    func triggerTrackingAuthorizationFlowIfNeeded() {
        requestTrackingAuthorizationIfNeededAndStartAppsFlyer()
    }

    /// Starts AppsFlyer once per launch and, on iOS 14+, requests ATT first when status is not determined.
    private func requestTrackingAuthorizationIfNeededAndStartAppsFlyer() {
        guard !hasStartedAppsFlyer else { return }
        guard #available(iOS 14, *) else {
            startAppsFlyerIfNeeded()
            return
        }

        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            startAppsFlyerIfNeeded()
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            ATTrackingManager.requestTrackingAuthorization { _ in
                self?.container?.logger.log("ATT authorization request completed")
                self?.startAppsFlyerIfNeeded()
            }
        }
    }

    /// Ensures AppsFlyer starts once even if app becomes active multiple times quickly.
    private func startAppsFlyerIfNeeded() {
        guard !hasStartedAppsFlyer else { return }
        hasStartedAppsFlyer = true
        AppsFlyerLib.shared().start()
    }

    /// Receives APNS device token, registers it with Firebase Messaging,
    /// and retrieves the corresponding FCM token.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        container.logger.log("APNS device token received")

        Task {
            do {
                let fcmToken = try await Messaging.messaging().token()
                container.logger.log("FCM token received: \(fcmToken)")
                container.fcmTokenDataSource.token = fcmToken
            } catch {
                container.logger.log("Failed to get FCM token: \(error.localizedDescription)", level: .error)
            }
        }
    }

    /// Returns currently supported interface orientations based on orientation lock state.
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }

    /// Handles universal links and forwards user activity to AppsFlyer.
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
}
