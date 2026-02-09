import Foundation
import Combine
import AppsFlyerLib
import FirebaseMessaging
import SwiftUI
import UserNotifications

/// <summary>
/// Coordinates application startup flow, processes attribution data,
/// communicates with backend services, and controls high-level app navigation state.
/// </summary>
@MainActor
final class AppViewModel: ObservableObject {

    /// <summary>
    /// Represents all possible high-level application states.
    /// </summary>
    enum AppState {
        case loading
        case game
        case web(URL)
        case firstLaunch(URL)
        case askNotifications(URL)
        case error(String)
        case noInternet
    }

    /// <summary>
    /// Current application state used to drive UI navigation.
    /// </summary>
    @Published var state: AppState = .loading

    /// <summary>
    /// Starts the application initialization flow and triggers conversion data processing.
    /// </summary>
    func start() {
        Task { @MainActor in
            state = .loading
            try? await Task.sleep(nanoseconds: 150_000_000)
            await fetchAndProcessConversionData()
        }
    }

    /// <summary>
    /// Executes main startup logic including configuration checks,
    /// attribution retrieval, payload creation, server communication,
    /// and final navigation state decision.
    /// </summary>
    private func fetchAndProcessConversionData() async {
        if AppConfig.shared.isInfinityLoading {
            state = .loading
            return
        }

        if AppConfig.shared.isNoNetwork {
            state = .noInternet
            return
        }

        if AppConfig.shared.isGameOnly {
            state = .game
            return
        }

        if AppConfig.shared.isWebOnly {
            if let url = URL(string: "https://example.com") {
                state = .web(url)
            }
            return
        }

        let conversionData = await getConversionData(timeout: 3.0)
        let afId = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
        let pushToken = await getFCMToken() ?? ""
        var payload = buildPayload(conversionData: conversionData, afId: afId, pushToken: pushToken)

        if AppConfig.shared.isDebug {
            payload["af_status"] = "Non-organic"
        }

        do {
            let responseData = try await sendPayloadToServer(payload)
            AppLogger.log("Server response: \(responseData)")

            let urlFromServer: URL? = {
                if let urlString = responseData["url"] as? String {
                    return URL(string: urlString)
                }
                return nil
            }()

            if AppConfig.shared.isAskNotifications, let url = urlFromServer {
                state = .askNotifications(url)
                return
            }

            let isFirstLaunch = !UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
            if isFirstLaunch {
                UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
                if let url = urlFromServer {
                    state = .firstLaunch(url)
                } else {
                    state = .game
                }
            } else if let url = urlFromServer {
                state = .web(url)
            } else {
                state = .game
            }

        } catch {
            AppLogger.log("Error sending payload: \(error.localizedDescription)")
            state = .game
        }
    }

    /// <summary>
    /// Builds a server payload by combining conversion data, device identifiers,
    /// application configuration values, and push token.
    /// </summary>
    private func buildPayload(conversionData: [AnyHashable: Any], afId: String, pushToken: String) -> [String: Any] {
        let allKeys: [String] = [
            "adset", "af_adset", "adgroup", "campaign_id", "af_status", "agency",
            "af_sub3", "af_siteid", "adset_id", "is_fb", "is_first_launch",
            "click_time", "iscache", "ad_id", "af_sub1", "campaign", "is_paid",
            "af_sub4", "adgroup_id", "is_mobile_data_terms_signed", "af_channel",
            "af_sub5", "media_source", "install_time", "af_sub2", "deep_link_sub1",
            "deep_link_value", "af_id", "bundle_id", "os", "store_id", "locale",
            "firebase_project_id", "push_token"
        ]

        let bundleId = Bundle.main.bundleIdentifier ?? "unknown.bundle"
        let locale = Locale.current.identifier

        var payload: [String: Any] = [:]
        for key in allKeys {
            switch key {
            case "af_id": payload[key] = afId
            case "bundle_id": payload[key] = bundleId
            case "os": payload[key] = AppConfig.shared.os
            case "store_id": payload[key] = AppConfig.shared.storeIdWithPrefix
            case "locale": payload[key] = locale
            case "firebase_project_id": payload[key] = AppConfig.shared.firebaseProjectId
            case "push_token": payload[key] = pushToken
            case "af_status":
                payload[key] = conversionData[key] ?? "Organic"
            default:
                payload[key] = conversionData[key] ?? ""
            }
        }
        return payload
    }

    /// <summary>
    /// Sends payload data to the backend server and returns parsed JSON response.
    /// </summary>
    private func sendPayloadToServer(_ payload: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: AppConfig.shared.serverURL) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }

        return json
    }

    /// <summary>
    /// Waits for AppsFlyer conversion data until timeout expires and returns the result.
    /// </summary>
    private func getConversionData(timeout: TimeInterval) async -> [AnyHashable: Any] {
        let start = Date()
        while ConversionDataStore.shared.conversionData == nil {
            try? await Task.sleep(nanoseconds: 200_000_000)
            if Date().timeIntervalSince(start) > timeout { break }
        }
        return ConversionDataStore.shared.conversionData ?? [:]
    }

    /// <summary>
    /// Requests Firebase Cloud Messaging token asynchronously.
    /// </summary>
    private func getFCMToken() async -> String? {
        await withCheckedContinuation { continuation in
            Messaging.messaging().token { token, _ in
                continuation.resume(returning: token)
            }
        }
    }
}
