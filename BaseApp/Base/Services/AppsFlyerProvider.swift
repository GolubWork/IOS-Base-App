import Foundation
import AppsFlyerLib

/// <summary>
/// Provides a centralized integration point for AppsFlyer SDK callbacks,
/// handles conversion and attribution events, and distributes them across the app.
/// Implemented as a singleton to ensure a single delegate instance.
/// </summary>
final class AppsFlyerProvider: NSObject, AppsFlyerLibDelegate {

    /// <summary>
    /// Shared singleton instance of <see cref="AppsFlyerProvider"/>.
    /// </summary>
    static let shared = AppsFlyerProvider()

    /// <summary>
    /// Private initializer to enforce singleton usage.
    /// </summary>
    private override init() {
        super.init()
    }

    /// <summary>
    /// Called when AppsFlyer successfully returns conversion data.
    /// Logs the result, updates stored conversion data, and posts a notification.
    /// </summary>
    /// <param name="conversionInfo">Dictionary containing conversion information.</param>
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        AppLogger.log("AppsFlyer conversion success: \(conversionInfo)")
        ConversionDataStore.shared.updateConversionData(conversionInfo)
        NotificationCenter.default.post(name: .didReceiveConversionData, object: conversionInfo)
    }

    /// <summary>
    /// Called when AppsFlyer fails to return conversion data.
    /// Logs the error and posts a failure notification.
    /// </summary>
    /// <param name="error">Error describing the failure.</param>
    func onConversionDataFail(_ error: Error) {
        AppLogger.log("AppsFlyer conversion fail: \(error.localizedDescription)")
        NotificationCenter.default.post(name: .didFailConversionData, object: error)
    }

    /// <summary>
    /// Called when AppsFlyer provides app open attribution data.
    /// Logs attribution details and posts a notification with attribution payload.
    /// </summary>
    /// <param name="attributionData">Dictionary containing attribution data.</param>
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        AppLogger.log("AppsFlyer attribution: \(attributionData)")
        NotificationCenter.default.post(name: .didReceiveAttributionData, object: attributionData)
    }

    /// <summary>
    /// Called when AppsFlyer fails to provide app open attribution data.
    /// Logs the error and posts a failure notification.
    /// </summary>
    /// <param name="error">Error describing the attribution failure.</param>
    func onAppOpenAttributionFailure(_ error: Error) {
        AppLogger.log("AppsFlyer attribution fail: \(error.localizedDescription)")
        NotificationCenter.default.post(name: .didFailAttribution, object: error)
    }
}

/// <summary>
/// Notification names used for broadcasting AppsFlyer conversion and attribution events.
/// </summary>
extension Notification.Name {

    /// <summary>
    /// Posted when conversion data is successfully received.
    /// </summary>
    static let didReceiveConversionData = Notification.Name("didReceiveConversionData")

    /// <summary>
    /// Posted when conversion data retrieval fails.
    /// </summary>
    static let didFailConversionData = Notification.Name("didFailConversionData")

    /// <summary>
    /// Posted when attribution data is successfully received.
    /// </summary>
    static let didReceiveAttributionData = Notification.Name("didReceiveAttributionData")

    /// <summary>
    /// Posted when attribution data retrieval fails.
    /// </summary>
    static let didFailAttribution = Notification.Name("didFailAttribution")
}
