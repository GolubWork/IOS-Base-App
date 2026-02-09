import Foundation

/// Local data source for Firebase Cloud Messaging token. Holds the current FCM token
/// for push notifications. Use via DI; no singleton.
final class FCMTokenLocalDataSource: FCMTokenDataSourceProtocol {

    /// Current FCM token.
    var token: String?

    init() {}
}
