import Foundation

/// Errors that can occur during server API communication.
enum ServerAPIRepositoryError: Error {
    /// Server URL is invalid.
    case invalidURL
    /// Transport-level error during the request.
    case transportError(Error)
    /// Server response is invalid or unexpected.
    case invalidResponse
    /// Server returned an error with a message.
    case serverError(String)
}

/// Network repository implementation: POST to config endpoint and parse web URL from JSON response.
/// Injected via DI; use `NetworkRepositoryProtocol` in domain/use cases.
final class ServerAPIRepository: NetworkRepositoryProtocol {

    private let configuration: AppConfigurationProtocol
    private let logger: Logging

    init(configuration: AppConfigurationProtocol, logger: Logging) {
        self.configuration = configuration
        self.logger = logger
    }

    func fetchWebURL(usingPayload payload: [AnyHashable: Any], timeout: TimeInterval = 10) async throws -> String? {
        guard let url = URL(string: configuration.serverURL) else {
            throw ServerAPIRepositoryError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        logger.log("ServerAPI: POST payload: \(payload)")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await withThrowingTaskGroup(of: (Data, URLResponse).self) { group in
                group.addTask {
                    try await URLSession.shared.data(for: request)
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    throw ServerAPIRepositoryError.invalidResponse
                }
                let result = try await group.next()!
                group.cancelAll()
                return result
            }
        } catch {
            throw ServerAPIRepositoryError.transportError(error)
        }

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ServerAPIRepositoryError.invalidResponse
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ServerAPIRepositoryError.invalidResponse
        }

        logger.log("ServerAPI: response JSON: \(json)")

        if let ok = json["ok"] as? Bool, ok,
           let urlString = json["url"] as? String, !urlString.isEmpty {
            return urlString
        }
        return nil
    }
}
