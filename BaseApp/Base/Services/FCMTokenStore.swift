/// <summary>
/// Stores the current Firebase Cloud Messaging token.
/// Implemented as a singleton to provide global access to the token state.
/// </summary>
final class FCMTokenStore {

    /// <summary>
    /// Shared singleton instance of <see cref="FCMTokenStore"/>.
    /// </summary>
    static let shared = FCMTokenStore()

    /// <summary>
    /// Current FCM token used for push notifications.
    /// </summary>
    var token: String?

    /// <summary>
    /// Private initializer to enforce singleton usage.
    /// </summary>
    private init() {}
}
