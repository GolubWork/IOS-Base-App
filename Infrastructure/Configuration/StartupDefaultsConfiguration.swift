import Foundation

/// Centralized startup defaults for runtime configuration (URLs, store/API identifiers, feature flags).
/// Edit these values per app clone; `AppConfiguration` uses them when Bundle/Info.plist keys are absent.
enum StartupDefaultsConfiguration {
    /// Example: "https://example.com/config.php"
    static let serverURL = ""
    /// Example: "1234567890"
    static let storeId = ""
    /// Example: "123456789012"
    static let firebaseProjectId = ""
    /// Example: "AbCdEfGhIjKlMnOpQrStUv"
    static let appsFlyerDevKey = ""

    /// Example: true for debug diagnostics builds.
    static let isDebug = false
    /// Example: true to always open game content.
    static let isGameOnly = false
    /// Example: true to always force web flow.
    static let isWebOnly = false
    /// Example: true to simulate no network startup.
    static let isNoNetwork = false
    /// Example: true to force notifications pre-screen.
    static let isAskNotifications = false
    /// Example: true to keep the app in loading state.
    static let isInfinityLoading = false
    /// Example: true to force opening test startup branch.
    static let isForceOpenTestState = false
}
