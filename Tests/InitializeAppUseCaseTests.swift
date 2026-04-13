import XCTest
@testable import BaseProject

final class InitializeAppUseCaseTests: XCTestCase {
    private var repeatDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        let suiteName = "InitializeAppUseCaseTests.\(UUID().uuidString)"
        repeatDefaults = UserDefaults(suiteName: suiteName)
        repeatDefaults.removePersistentDomain(forName: suiteName)
        AskNotificationsRepeatState.userDefaults = repeatDefaults
    }

    override func tearDown() {
        AskNotificationsRepeatState.userDefaults = .standard
        repeatDefaults = nil
        super.tearDown()
    }

    func testExecuteReturnsNoInternetWhenPathUnsatisfiedAndAPNSPending() async {
        let logger = CaptureLogger()
        let fcm = MockFCMTokenDataSource()
        fcm.apnsStatus = "pending"
        fcm.token = nil
        let connectivity = FixedNetworkConnectivityChecker(reachable: false)
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: ["af_status": "Non-organic"]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .success("https://example.com")),
            networkConnectivityChecker: connectivity,
            fcmTokenDataSource: fcm,
            startupStateStore: InMemoryStartupStateStore(),
            logger: logger,
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: nil, hasLaunchedBefore: true)

        XCTAssertEqual(state, .noInternet)
    }

    func testExecuteReturnsNoInternetOnFirstLaunchWhenOfflineBeforeConfigCheck() async {
        let startupStateStore = InMemoryStartupStateStore()
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .success("https://example.com")),
            networkConnectivityChecker: FixedNetworkConnectivityChecker(reachable: false),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: startupStateStore,
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: false)

        XCTAssertEqual(state, .noInternet)
        XCTAssertEqual(startupStateStore.mode, .unresolved)
    }

    func testExecuteReturnsNoInternetForPersistedWebModeWhenOfflineBeforeConfigCheck() async {
        let startupStateStore = InMemoryStartupStateStore()
        startupStateStore.mode = .web
        startupStateStore.cachedWebConfig = CachedWebConfig(
            urlString: "https://cached.example.com",
            expiresAt: Date().addingTimeInterval(3600)
        )
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .success("https://example.com")),
            networkConnectivityChecker: FixedNetworkConnectivityChecker(reachable: false),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: startupStateStore,
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .noInternet)
    }

    func testExecuteReturnsNoInternetForPersistedGameModeWhenOfflineBeforeConfigCheck() async {
        let startupStateStore = InMemoryStartupStateStore()
        startupStateStore.mode = .native
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .success("https://example.com")),
            networkConnectivityChecker: FixedNetworkConnectivityChecker(reachable: false),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: startupStateStore,
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .noInternet)
    }

    func testExecuteReturnsGameAndLogsWhenNetworkFails() async {
        let logger = CaptureLogger()
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .failure(MockError.generic)),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: logger,
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .native)
        XCTAssertTrue(
            logger.messages.contains(where: { $0.contains("InitializeAppUseCase network request failed") }),
            "Expected network failure to be logged."
        )
    }

    func testExecuteReturnsGameOnFirstLaunchWhenServerRequestFails() async {
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .failure(MockError.generic)),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: false)

        XCTAssertEqual(state, .native)
    }

    func testExecuteRefreshesConversionDataOnFirstLaunchWhenStatusIsOrganic() async {
        let logger = CaptureLogger()
        let fetchConversionUseCase = MockFetchConversionDataUseCase(results: [
            ["af_status": "Organic"],
            ["af_status": "Non-organic", "campaign": "retargeting"]
        ])
        let analyticsRepository = MockAnalyticsRepository()
        let networkRepository = CaptureNetworkRepository(result: .success("https://example.com"))
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: fetchConversionUseCase,
            analyticsRepository: analyticsRepository,
            networkRepository: networkRepository,
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: logger,
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        _ = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: false)

        XCTAssertEqual(fetchConversionUseCase.callCount, 2, "Expected second conversion fetch after organic first payload.")
        XCTAssertEqual(analyticsRepository.refreshInstallConversionDataCallCount, 1, "Expected conversion refresh call.")
        XCTAssertEqual(networkRepository.capturedPayload?["af_status"] as? String, "Non-organic")
    }

    func testExecuteReturnsAskNotificationsWhenRepeatWindowElapsedAndKeepsPendingUntilUserChoice() async {
        AskNotificationsRepeatState.markSkipped(
            now: Date(timeIntervalSince1970: 0),
            defaults: repeatDefaults
        )
        let logger = CaptureLogger()
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(isAskNotifications: false),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .success("https://example.com/deeplink")),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: logger,
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .askNotifications(URL(string: "https://example.com/deeplink")!))
        XCTAssertTrue(
            AskNotificationsRepeatState.shouldShowRepeat(
                now: Date(timeIntervalSince1970: 4 * 24 * 60 * 60),
                defaults: repeatDefaults
            ),
            "Expected pending repeat flag to stay active until user grants notifications."
        )
    }

    func testExecuteReturnsAskNotificationsWithFallbackURLWhenDebugFlagEnabledAndServerURLIsMissing() async {
        let networkRepository = CaptureNetworkRepository(result: .success(nil))
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(isAskNotifications: true),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: networkRepository,
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .askNotifications(URL(string: "https://example.com/config")!))
        XCTAssertNil(networkRepository.capturedPayload, "Expected askNotifications shortcut to skip server request.")
    }

    func testHandleAuthorizationResultDeniedSchedulesRepeat() {
        AskNotificationsRepeatState.handleAuthorizationResult(
            granted: false,
            now: Date(timeIntervalSince1970: 0),
            defaults: repeatDefaults
        )

        XCTAssertTrue(
            AskNotificationsRepeatState.shouldShowRepeat(
                now: Date(timeIntervalSince1970: 4 * 24 * 60 * 60),
                defaults: repeatDefaults
            ),
            "Expected denied permission to schedule repeated ask."
        )
    }

    func testExecuteUsesCachedWebURLWhenNetworkFails() async {
        let logger = CaptureLogger()
        let startupStateStore = InMemoryStartupStateStore()
        startupStateStore.mode = .web
        startupStateStore.cachedWebConfig = CachedWebConfig(
            urlString: "https://cached.example.com",
            expiresAt: Date().addingTimeInterval(3600)
        )
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .failure(MockError.generic)),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: startupStateStore,
            logger: logger,
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .web(URL(string: "https://cached.example.com")!))
    }

    func testExecuteDisablesFutureConfigRequestsAfterFirstLaunchWithoutURL() async {
        let startupStateStore = InMemoryStartupStateStore()
        let fcmDataSource = MockFCMTokenDataSource()
        fcmDataSource.apnsStatus = "registered"
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .success(nil)),
            fcmTokenDataSource: fcmDataSource,
            startupStateStore: startupStateStore,
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let firstLaunchState = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: false)
        let secondLaunchState = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(firstLaunchState, .native)
        XCTAssertEqual(secondLaunchState, .native)
        XCTAssertTrue(startupStateStore.isConfigRequestsDisabled)
        XCTAssertEqual(startupStateStore.mode, .native)
    }

    func testExecuteReturnsGameWhenAPNSPendingOnFirstLaunchAndServerHasNoURL() async {
        let startupStateStore = InMemoryStartupStateStore()
        let fcmDataSource = MockFCMTokenDataSource()
        fcmDataSource.apnsStatus = "pending"
        let networkRepository = CaptureNetworkRepository(result: .success(nil))
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: networkRepository,
            fcmTokenDataSource: fcmDataSource,
            startupStateStore: startupStateStore,
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let firstLaunchState = await useCase.execute(pushToken: nil, hasLaunchedBefore: false)

        XCTAssertEqual(firstLaunchState, .native)
        XCTAssertNotNil(networkRepository.capturedPayload, "Expected request to be sent even when APNS is pending.")
        XCTAssertTrue(startupStateStore.isConfigRequestsDisabled)
        XCTAssertEqual(startupStateStore.mode, .native)
    }

    func testExecuteMergesAttributionWithoutOverridingConversionKeys() async {
        let analyticsRepository = MockAnalyticsRepository(
            attributionData: ["campaign": "udl_campaign", "deep_link": "https://example.com/udl"]
        )
        let networkRepository = CaptureNetworkRepository(result: .success("https://example.com"))
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(
                result: ["af_status": "Non-organic", "campaign": "conversion_campaign"]
            ),
            analyticsRepository: analyticsRepository,
            networkRepository: networkRepository,
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        _ = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(networkRepository.capturedPayload?["campaign"] as? String, "conversion_campaign")
        XCTAssertEqual(networkRepository.capturedPayload?["deep_link"] as? String, "https://example.com/udl")
    }

    func testExecuteOverridesAfStatusWhenAttributionIsNonOrganic() async {
        let logger = CaptureLogger()
        let analyticsRepository = MockAnalyticsRepository(
            attributionData: [
                "af_status": "Non-organic",
                "campaign": "udl_campaign"
            ]
        )
        let networkRepository = CaptureNetworkRepository(result: .success("https://example.com"))
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(
                result: [
                    "af_status": "Organic",
                    "campaign": "conversion_campaign"
                ]
            ),
            analyticsRepository: analyticsRepository,
            networkRepository: networkRepository,
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: logger,
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        _ = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(networkRepository.capturedPayload?["af_status"] as? String, "Non-organic")
        // Keep conversion key priority for non-special fields.
        XCTAssertEqual(networkRepository.capturedPayload?["campaign"] as? String, "conversion_campaign")
    }

    func testExecuteIgnoresDebugFlagsWhenIsDebugIsFalse() async {
        let networkRepository = CaptureNetworkRepository(result: .success("https://example.com"))
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(
                isDebug: false,
                isGameOnly: true,
                isWebOnly: true,
                isNoNetwork: true,
                isAskNotifications: true,
                isInfinityLoading: true
            ),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: networkRepository,
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .web(URL(string: "https://example.com")!))
    }

    func testExecuteReturnsGameWhenDebugGameOnlyIsEnabledEvenOffline() async {
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(isDebug: true, isGameOnly: true),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .failure(MockError.generic)),
            networkConnectivityChecker: FixedNetworkConnectivityChecker(reachable: false),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: nil, hasLaunchedBefore: true)

        XCTAssertEqual(state, .native)
    }

    func testExecuteReturnsNoInternetWhenDebugNoNetworkIsEnabled() async {
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(isDebug: true, isNoNetwork: true),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .success("https://example.com")),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .noInternet)
    }

    func testExecuteReturnsLoadingWhenDebugInfinityLoadingIsEnabled() async {
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(isDebug: true, isInfinityLoading: true),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .success("https://example.com")),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .loading)
    }

    func testExecuteForcesWebStateInDebugWebOnlyWhenServerReturnsNilURL() async {
        let useCase = InitializeAppUseCase(
            configuration: MockAppConfiguration(isDebug: true, isWebOnly: true),
            fetchConversionDataUseCase: MockFetchConversionDataUseCase(result: [:]),
            analyticsRepository: MockAnalyticsRepository(),
            networkRepository: MockNetworkRepository(result: .success(nil)),
            fcmTokenDataSource: MockFCMTokenDataSource(),
            startupStateStore: InMemoryStartupStateStore(),
            logger: CaptureLogger(),
            organicRefreshDelay: 0,
            preRequestWaitTimeout: 0
        )

        let state = await useCase.execute(pushToken: "push-token", hasLaunchedBefore: true)

        XCTAssertEqual(state, .web(URL(string: "https://example.com/config")!))
    }
}

private final class CaptureLogger: Logging {
    private(set) var messages: [String] = []

    func log(_ message: String, level: LogLevel) {
        messages.append(message)
    }
}

private enum MockError: Error {
    case generic
}

private final class MockAppConfiguration: AppConfigurationProtocol {
    let serverURL: String = "https://example.com/config"
    let storeId: String = "6759390373"
    let firebaseProjectId: String = "487557931280"
    let appsFlyerDevKey: String = "dev-key"
    var storeIdWithPrefix: String { "id\(storeId)" }
    let os: String = "iOS"
    let noInternetMessage: String = ""
    let notificationSubtitle: String = ""
    let notificationDescription: String = ""
    let isDebug: Bool
    let isGameOnly: Bool
    let isWebOnly: Bool
    let isNoNetwork: Bool
    let isAskNotifications: Bool
    let isInfinityLoading: Bool
    let isForceOpenTestState: Bool = false

    init(
        isDebug: Bool = false,
        isAskNotifications: Bool = false,
        isGameOnly: Bool = false,
        isWebOnly: Bool = false,
        isNoNetwork: Bool = false,
        isInfinityLoading: Bool = false
    ) {
        self.isDebug = isDebug
        self.isAskNotifications = isAskNotifications
        self.isGameOnly = isGameOnly
        self.isWebOnly = isWebOnly
        self.isNoNetwork = isNoNetwork
        self.isInfinityLoading = isInfinityLoading
    }
}

private final class MockFetchConversionDataUseCase: FetchConversionDataUseCaseProtocol {
    private var results: [[AnyHashable: Any]]
    private(set) var callCount = 0

    convenience init(result: [AnyHashable: Any]) {
        self.init(results: [result])
    }

    init(results: [[AnyHashable: Any]]) {
        self.results = results
    }

    func execute() async -> [AnyHashable: Any] {
        callCount += 1
        guard !results.isEmpty else { return [:] }
        if results.count == 1 {
            return results[0]
        }
        return results.removeFirst()
    }
}

private final class MockAnalyticsRepository: AnalyticsRepositoryProtocol {
    private(set) var refreshInstallConversionDataCallCount = 0
    private let attributionData: [AnyHashable: Any]

    init(attributionData: [AnyHashable: Any] = [:]) {
        self.attributionData = attributionData
    }

    func getAnalyticsUserId() -> String? { "af-id" }

    func refreshInstallConversionData() {
        refreshInstallConversionDataCallCount += 1
    }

    func getLatestAttributionData() -> [AnyHashable: Any] {
        attributionData
    }

    func fetchInstallConversionDataSnapshot() async -> [AnyHashable: Any]? {
        nil
    }
}

private struct FixedNetworkConnectivityChecker: NetworkConnectivityCheckingProtocol {
    let reachable: Bool
    func isNetworkReachable() async -> Bool { reachable }
}

private final class MockFCMTokenDataSource: FCMTokenDataSourceProtocol {
    var token: String?
    var apnsStatus: String = "pending"
    var apnsErrorDescription: String?
    var isRegisteredForRemoteNotifications: Bool = false
    var notificationAuthorizationStatus: String = "unknown"
}

private final class MockNetworkRepository: NetworkRepositoryProtocol {
    private let result: Result<ConfigFetchResult, Error>

    init(result: Result<String?, Error>) {
        switch result {
        case .success(let value):
            self.result = .success(ConfigFetchResult(urlString: value, expiresAt: nil))
        case .failure(let error):
            self.result = .failure(error)
        }
    }

    init(configResult: Result<ConfigFetchResult, Error>) {
        self.result = configResult
    }

    func fetchConfig(usingPayload payload: [AnyHashable: Any], timeout: TimeInterval) async throws -> ConfigFetchResult {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

private final class CaptureNetworkRepository: NetworkRepositoryProtocol {
    private let result: Result<ConfigFetchResult, Error>
    private(set) var capturedPayload: [AnyHashable: Any]?

    init(result: Result<String?, Error>) {
        switch result {
        case .success(let value):
            self.result = .success(ConfigFetchResult(urlString: value, expiresAt: nil))
        case .failure(let error):
            self.result = .failure(error)
        }
    }

    func fetchConfig(usingPayload payload: [AnyHashable: Any], timeout: TimeInterval) async throws -> ConfigFetchResult {
        capturedPayload = payload
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

private final class InMemoryStartupStateStore: StartupStateStoreProtocol {
    var mode: StartupMode = .unresolved
    var isConfigRequestsDisabled: Bool = false
    var cachedWebConfig: CachedWebConfig?
}
