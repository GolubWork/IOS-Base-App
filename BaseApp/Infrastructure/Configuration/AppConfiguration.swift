import Foundation

/// Keys for configuration values injected from Build Settings / Info.plist (see xcconfig and INFOPLIST_KEY_*).
enum AppConfigurationBundleKey {
    static let serverURL = "SERVER_URL"
    static let storeId = "STORE_ID"
    static let firebaseProjectId = "FIREBASE_PROJECT_ID"
    static let appsFlyerDevKey = "APPSFLYER_DEV_KEY"
}

/// Default implementation of app configuration.
/// Server/API keys are read from Bundle (Info.plist) — set via xcconfig/Build Settings per scheme (Debug/Staging/Release).
/// Fallback defaults are used when keys are missing (e.g. running from Xcode without xcconfig attached).
final class AppConfiguration: AppConfigurationProtocol {

    // MARK: - Server & identifiers (from Bundle / xcconfig)

    let serverURL: String
    let storeId: String
    let firebaseProjectId: String
    let appsFlyerDevKey: String

    var storeIdWithPrefix: String {
        "id" + storeId
    }

    // MARK: - UI / copy

    let os: String
    let noInternetMessage: String
    let notificationSubtitle: String
    let notificationDescription: String

    // MARK: - Debug / feature flags

    let isDebug: Bool
    let isGameOnly: Bool
    let isWebOnly: Bool
    let isNoNetwork: Bool
    let isAskNotifications: Bool
    let isInfinityLoading: Bool

    // MARK: - Defaults (fallback when not in Bundle/xcconfig)

    private static let defaultServerURL = "https://laughingdropspop.com/config.php"
    private static let defaultStoreId = "6756708872"
    private static let defaultFirebaseProjectId = "662865312172"
    private static let defaultAppsFlyerDevKey = "zjmEk65LDPa3K8s4BWnpfA"

    // MARK: - Initialization

    init(
        serverURL: String? = nil,
        storeId: String? = nil,
        firebaseProjectId: String? = nil,
        appsFlyerDevKey: String? = nil,
        os: String = "iOS",
        noInternetMessage: String = "Please, check your internet connection and restart",
        notificationSubtitle: String = "Allow notifications about bonuses and promos",
        notificationDescription: String = "Stay tuned with best offers from our casino",
        isDebug: Bool = false,
        isGameOnly: Bool = true,
        isWebOnly: Bool = false,
        isNoNetwork: Bool = false,
        isAskNotifications: Bool = false,
        isInfinityLoading: Bool = false,
        bundle: Bundle = .main
    ) {
        let info = bundle.infoDictionary ?? [:]
        self.serverURL = serverURL
            ?? (info[AppConfigurationBundleKey.serverURL] as? String)
            ?? Self.defaultServerURL
        self.storeId = storeId
            ?? (info[AppConfigurationBundleKey.storeId] as? String)
            ?? Self.defaultStoreId
        self.firebaseProjectId = firebaseProjectId
            ?? (info[AppConfigurationBundleKey.firebaseProjectId] as? String)
            ?? Self.defaultFirebaseProjectId
        self.appsFlyerDevKey = appsFlyerDevKey
            ?? (info[AppConfigurationBundleKey.appsFlyerDevKey] as? String)
            ?? Self.defaultAppsFlyerDevKey
        self.os = os
        self.noInternetMessage = noInternetMessage
        self.notificationSubtitle = notificationSubtitle
        self.notificationDescription = notificationDescription
        self.isDebug = isDebug
        self.isGameOnly = isGameOnly
        self.isWebOnly = isWebOnly
        self.isNoNetwork = isNoNetwork
        self.isAskNotifications = isAskNotifications
        self.isInfinityLoading = isInfinityLoading
    }
}
