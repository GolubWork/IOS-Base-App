import Foundation

/// <summary>
/// Represents errors that can occur during server API communication.
/// </summary>
enum ServerAPIError: Error {
    /// <summary>
    /// Indicates that the server URL is invalid.
    /// </summary>
    case invalidURL

    /// <summary>
    /// Indicates a transport-level error occurred during the request.
    /// </summary>
    case transportError(Error)

    /// <summary>
    /// Indicates that the server response is invalid or unexpected.
    /// </summary>
    case invalidResponse

    /// <summary>
    /// Indicates that the server returned an error with a message.
    /// </summary>
    case serverError(String)
}

/// <summary>
/// Provides networking functionality for communicating with the backend server.
/// Implemented as a singleton to centralize API access.
/// </summary>
final class ServerAPI {

    /// <summary>
    /// Shared singleton instance of ServerAPI.
    /// </summary>
    static let shared = ServerAPI()

    /// <summary>
    /// Private initializer to enforce singleton usage.
    /// </summary>
    private init() {}

    /// <summary>
    /// Sends conversion data to the server and attempts to retrieve a web URL from the response.
/// </summary>
    func fetchWebURL(using conversionData: [AnyHashable: Any]?,
                     timeout: TimeInterval = 10) async throws -> String? {

        guard let url = URL(string: AppConfig.shared.serverURL) else {
            throw ServerAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = conversionData ?? [:]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        AppLogger.log("ServerAPI: POST payload: \(payload)")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await withThrowingTaskGroup(of: (Data, URLResponse).self) { group in
                group.addTask {
                    try await URLSession.shared.data(for: request)
                }

                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    throw ServerAPIError.invalidResponse
                }

                let result = try await group.next()!
                group.cancelAll()
                return result
            }
        } catch {
            throw ServerAPIError.transportError(error)
        }

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ServerAPIError.invalidResponse
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ServerAPIError.invalidResponse
        }

        AppLogger.log("ServerAPI: response JSON: \(json)")

        if let ok = json["ok"] as? Bool, ok,
           let urlString = json["url"] as? String, !urlString.isEmpty {
            return urlString
        } else {
            return nil
        }
    }
}
