import Foundation

/// Protocol for providing conversion/attribution data (e.g. from AppsFlyer).
/// Allows waiting for data with timeout and swapping implementations for tests.
protocol ConversionDataRepositoryProtocol: AnyObject {

    /// Returns conversion data when available, or after timeout expires.
    /// - Parameter timeout: Maximum time to wait in seconds.
    /// - Returns: Conversion data dictionary; may be empty if timeout reached.
    func getConversionData(timeout: TimeInterval) async -> [AnyHashable: Any]
}
