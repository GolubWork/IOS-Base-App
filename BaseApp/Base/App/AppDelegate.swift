import UIKit
import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging
import UserNotifications

/// <summary>
/// Application delegate responsible for configuring Firebase, AppsFlyer,
/// push notifications, and handling application lifecycle events.
/// </summary>
final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    /// <summary>
    /// Current orientation lock used to restrict supported interface orientations.
    /// </summary>
    var orientationLock: UIInterfaceOrientationMask = .portrait

    /// <summary>
    /// Performs application startup configuration including Firebase setup,
    /// push notification registration, and AppsFlyer initialization.
    /// </summary>
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()

        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = AppConfig.shared.appsFlyerDevKey
        appsFlyer.appleAppID = AppConfig.shared.storeIdWithPrefix
        appsFlyer.delegate = AppsFlyerProvider.shared
        appsFlyer.isDebug = AppConfig.shared.isDebug

        appsFlyer.start()

        return true
    }

    /// <summary>
    /// Notifies AppsFlyer when the application becomes active.
    /// </summary>
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }

    /// <summary>
    /// Receives APNS device token, registers it with Firebase Messaging,
    /// and retrieves the corresponding FCM token.
    /// </summary>
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        AppLogger.log("APNS device token received")

        Task {
            do {
                let fcmToken = try await Messaging.messaging().token()
                AppLogger.log("FCM token received: \(fcmToken)")
                FCMTokenStore.shared.token = fcmToken
            } catch {
                AppLogger.log("Failed to get FCM token: \(error.localizedDescription)", level: .error)
            }
        }
    }

    /// <summary>
    /// Returns currently supported interface orientations based on orientation lock state.
    /// </summary>
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }

    /// <summary>
    /// Handles universal links and forwards user activity to AppsFlyer.
    /// </summary>
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
}
