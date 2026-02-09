import Foundation

/// Protocol for analytics (e.g. AppsFlyer) integration.
/// Allows swapping implementations for tests or different providers.
protocol AnalyticsRepositoryProtocol: AnyObject {

    /// Returns the analytics provider user ID (e.g. AppsFlyer UID) used for attribution and payloads.
    func getAnalyticsUserId() -> String?
}
