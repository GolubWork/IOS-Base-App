import Foundation
import Combine

/// <summary>
/// Stores AppsFlyer conversion data and exposes it as an observable state.
/// Implemented as a singleton to provide a single source of truth across the app.
/// </summary>
final class ConversionDataStore: ObservableObject {

    /// <summary>
    /// Shared singleton instance of <see cref="ConversionDataStore"/>.
    /// </summary>
    static let shared = ConversionDataStore()

    /// <summary>
    /// Current conversion data received from AppsFlyer.
    /// Published to notify subscribers about updates.
    /// </summary>
    @Published private(set) var conversionData: [AnyHashable: Any]? = nil

    /// <summary>
    /// Private initializer to enforce singleton usage.
    /// </summary>
    private init() {
        #if DEBUG
        conversionData = nil
        #endif
    }

    /// <summary>
    /// Merges new conversion data with existing stored data and notifies subscribers.
    /// </summary>
    /// <param name="data">New conversion data to merge into storage.</param>
    func updateConversionData(_ data: [AnyHashable: Any]) {
        var merged = conversionData ?? [:]
        for (k, v) in data { merged[k] = v }
        conversionData = merged
        AppLogger.log("ConversionDataStore updated: \(merged)")
    }

    /// <summary>
    /// Clears all stored conversion data and notifies subscribers.
    /// </summary>
    func clear() {
        conversionData = nil
    }
}
