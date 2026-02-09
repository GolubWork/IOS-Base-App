import Foundation

/// Represents all possible high-level application states used to drive UI navigation.
enum AppState: Equatable {
    /// Initial loading state while attribution and config are being resolved.
    case loading
    /// User should see the game (main content).
    case game
    /// User should see WebView with the given URL.
    case web(URL)
    /// First launch flow with optional URL for post-onboarding.
    case firstLaunch(URL)
    /// Prompt for notification permission before showing content at URL.
    case askNotifications(URL)
    /// Application error with user-facing message.
    case error(String)
    /// No network connectivity.
    case noInternet
}
