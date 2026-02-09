import Foundation
import os

/// Default logging implementation: writes to OSLog and appends to the injected log storage.
final class DefaultLogger: Logging {

    private let subsystem: String
    private let category: String
    private let storage: LogStorageProtocol
    private lazy var osLogger = Logger(subsystem: subsystem, category: category)

    init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "BaseApp",
        category: String = "App",
        storage: LogStorageProtocol
    ) {
        self.subsystem = subsystem
        self.category = category
        self.storage = storage
    }

    func log(_ message: String, level: LogLevel = .info) {
        switch level {
        case .debug:
            osLogger.debug("\(message)")
        case .error:
            osLogger.error("\(message)")
        case .fault:
            osLogger.fault("\(message)")
        case .info:
            osLogger.log("\(message)")
        }
        storage.append(message: message)
    }
}
