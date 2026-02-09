import Foundation
import Combine

/// <summary>
/// Stores application logs in memory and persists them to a file.
/// Provides observable log updates for UI or debugging tools.
/// </summary>
final class LogStore: ObservableObject {

    /// <summary>
    /// Shared singleton instance of LogStore.
    /// </summary>
    static let shared = LogStore()

    /// <summary>
    /// In-memory collection of log lines.
    /// </summary>
    @Published private(set) var lines: [String] = []

    /// <summary>
    /// File URL where logs are persisted.
    /// </summary>
    private let fileURL: URL

    /// <summary>
    /// Initializes log storage, resolves file path, and loads existing logs from disk.
    /// </summary>
    private init() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("app_logs.txt")
        loadFromFile()
    }

    /// <summary>
    /// Loads existing log lines from the persistent file into memory.
    /// </summary>
    private func loadFromFile() {
        if let data = try? Data(contentsOf: fileURL),
           let content = String(data: data, encoding: .utf8) {
            lines = content.components(separatedBy: .newlines)
        }
    }

    /// <summary>
    /// Appends a new log message with timestamp, updates observers, and persists logs to file.
    /// </summary>
    func append(message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(timestamp)] \(message)"
        DispatchQueue.main.async {
            self.lines.append(line)
            self.trimIfNeeded()
            self.saveToFile()
        }
    }

    /// <summary>
    /// Ensures the in-memory log buffer does not exceed the maximum allowed number of entries.
    /// </summary>
    private func trimIfNeeded() {
        if lines.count > 2000 {
            lines.removeFirst(lines.count - 2000)
        }
    }

    /// <summary>
    /// Saves the current in-memory log lines to the persistent log file.
    /// </summary>
    private func saveToFile() {
        let content = lines.joined(separator: "\n")
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
        }
    }

    /// <summary>
    /// Clears all in-memory logs and removes the persistent log file.
    /// </summary>
    func clear() {
        lines = []
        try? FileManager.default.removeItem(at: fileURL)
    }
}
