import Foundation
import os

/// <summary>
/// Provides centralized logging functionality using OSLog and file-based logging.
/// </summary>
struct AppLogger {

    /// <summary>
    /// Application subsystem identifier used for OSLog.
    /// </summary>
    private static let subsystem = Bundle.main.bundleIdentifier ?? "LaughingDrops"

    /// <summary>
    /// OSLog logger instance used for system console logging.
    /// </summary>
    private static let logger = Logger(subsystem: subsystem, category: "App")

    /// <summary>
    /// Logs a message to OSLog and appends it to the persistent log store.
/// </summary>
    static func log(_ message: String, level: OSLogType = .default) {
        switch level {
        case .debug:
            logger.debug("\(message)")
        case .error:
            logger.error("\(message)")
        case .fault:
            logger.fault("\(message)")
        default:
            logger.log("\(message)")
        }

        LogStore.shared.append(message: message)
    }
}
