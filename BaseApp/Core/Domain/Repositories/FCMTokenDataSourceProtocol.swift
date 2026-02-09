import Foundation

/// Protocol for reading and writing FCM (Firebase Cloud Messaging) token in local storage.
/// Used by AppDelegate to store token and by ViewModels to build payloads.
protocol FCMTokenDataSourceProtocol: AnyObject {

    /// Current FCM token used for push notifications.
    var token: String? { get set }
}
