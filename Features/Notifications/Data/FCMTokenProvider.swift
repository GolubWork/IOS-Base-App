import Foundation
import FirebaseMessaging

/// Provides FCM push token: uses cached value from data source first,
/// then requests from Firebase Messaging if needed.
final class FCMTokenProvider: PushTokenProviderProtocol {

    private let fcmTokenDataSource: FCMTokenDataSourceProtocol

    init(fcmTokenDataSource: FCMTokenDataSourceProtocol) {
        self.fcmTokenDataSource = fcmTokenDataSource
    }

    func getToken() async -> String? {
        if let cached = fcmTokenDataSource.token {
            return cached
        }
        return await withCheckedContinuation { continuation in
            Messaging.messaging().token { token, _ in
                if let token = token {
                    self.fcmTokenDataSource.token = token
                }
                continuation.resume(returning: token)
            }
        }
    }
}
