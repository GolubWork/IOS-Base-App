import Foundation

/// Payload keys used when building server request (aligned with backend expectations).
private enum PayloadKey {
    static let allKeys: [String] = [
        "adset", "af_adset", "adgroup", "campaign_id", "af_status", "agency",
        "af_sub3", "af_siteid", "adset_id", "is_fb", "is_first_launch",
        "click_time", "iscache", "ad_id", "af_sub1", "campaign", "is_paid",
        "af_sub4", "adgroup_id", "is_mobile_data_terms_signed", "af_channel",
        "af_sub5", "media_source", "install_time", "af_sub2", "deep_link_sub1",
        "deep_link_value", "af_id", "bundle_id", "os", "store_id", "locale",
        "firebase_project_id", "push_token"
    ]
}

/// Use case: run app initialization (config checks, conversion data, server request, state resolution).
/// Conforms to AppInitializerUseCaseProtocol from AppInitialization feature.
final class InitializeAppUseCase: AppInitializerUseCaseProtocol {

    private let configuration: AppConfigurationProtocol
    private let fetchConversionDataUseCase: FetchConversionDataUseCaseProtocol
    private let analyticsRepository: AnalyticsRepositoryProtocol
    private let networkRepository: NetworkRepositoryProtocol

    init(
        configuration: AppConfigurationProtocol,
        fetchConversionDataUseCase: FetchConversionDataUseCaseProtocol,
        analyticsRepository: AnalyticsRepositoryProtocol,
        networkRepository: NetworkRepositoryProtocol
    ) {
        self.configuration = configuration
        self.fetchConversionDataUseCase = fetchConversionDataUseCase
        self.analyticsRepository = analyticsRepository
        self.networkRepository = networkRepository
    }

    func execute(pushToken: String?, hasLaunchedBefore: Bool) async -> AppState {
        if configuration.isInfinityLoading {
            return .loading
        }
        if configuration.isNoNetwork {
            return .noInternet
        }
        if configuration.isGameOnly {
            return .game
        }
        if configuration.isWebOnly {
            if let url = URL(string: "https://example.com") {
                return .web(url)
            }
            return .game
        }

        let conversionData = await fetchConversionDataUseCase.execute(timeout: 3.0)
        let afId = analyticsRepository.getAnalyticsUserId() ?? ""
        let pushTokenValue = pushToken ?? ""
        var payload = buildPayload(
            conversionData: conversionData,
            afId: afId,
            pushToken: pushTokenValue
        )

        if configuration.isDebug {
            payload["af_status"] = "Non-organic"
        }

        do {
            let urlString = try await networkRepository.fetchWebURL(
                usingPayload: payload as [AnyHashable: Any],
                timeout: 30.0
            )
            let urlFromServer = urlString.flatMap { URL(string: $0) }

            if configuration.isAskNotifications, let url = urlFromServer {
                return .askNotifications(url)
            }

            if !hasLaunchedBefore {
                if let url = urlFromServer {
                    return .firstLaunch(url)
                } else {
                    return .game
                }
            }
            if let url = urlFromServer {
                return .web(url)
            }
            return .game
        } catch {
            return .game
        }
    }

    private func buildPayload(
        conversionData: [AnyHashable: Any],
        afId: String,
        pushToken: String
    ) -> [String: Any] {
        let bundleId = Bundle.main.bundleIdentifier ?? "unknown.bundle"
        let locale = Locale.current.identifier

        var payload: [String: Any] = [:]
        for key in PayloadKey.allKeys {
            switch key {
            case "af_id": payload[key] = afId
            case "bundle_id": payload[key] = bundleId
            case "os": payload[key] = configuration.os
            case "store_id": payload[key] = configuration.storeIdWithPrefix
            case "locale": payload[key] = locale
            case "firebase_project_id": payload[key] = configuration.firebaseProjectId
            case "push_token": payload[key] = pushToken
            case "af_status":
                payload[key] = conversionData[key] ?? "Organic"
            default:
                payload[key] = conversionData[key] ?? ""
            }
        }
        return payload
    }
}
