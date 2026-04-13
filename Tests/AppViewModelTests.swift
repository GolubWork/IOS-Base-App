import XCTest
@testable import BaseProject

@MainActor
final class AppViewModelTests: XCTestCase {

    func testPendingDeepLinkTransitionsToNoInternetWhenOffline() async {
        let viewModel = AppViewModel(
            initializeAppUseCase: MockAppInitializerUseCase(resultState: .native),
            pushTokenProvider: MockPushTokenProvider(token: "push-token"),
            networkConnectivityChecker: FixedConnectivityChecker(isReachable: false),
            configuration: MockViewModelConfiguration()
        )
        let deepLinkURL = URL(string: "https://example.com/deep-link")!

        viewModel.openDeepLink(url: deepLinkURL)
        viewModel.start()
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(viewModel.state, .noInternet)
    }

    func testPendingDeepLinkTransitionsToWebWhenOnline() async {
        let viewModel = AppViewModel(
            initializeAppUseCase: MockAppInitializerUseCase(resultState: .native),
            pushTokenProvider: MockPushTokenProvider(token: "push-token"),
            networkConnectivityChecker: FixedConnectivityChecker(isReachable: true),
            configuration: MockViewModelConfiguration()
        )
        let deepLinkURL = URL(string: "https://example.com/deep-link")!

        viewModel.openDeepLink(url: deepLinkURL)
        viewModel.start()
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(viewModel.state, .web(deepLinkURL))
    }

    func testPendingDeepLinkDoesNotOverrideNoInternetResolvedState() async {
        let viewModel = AppViewModel(
            initializeAppUseCase: MockAppInitializerUseCase(resultState: .noInternet),
            pushTokenProvider: MockPushTokenProvider(token: "push-token"),
            networkConnectivityChecker: FixedConnectivityChecker(isReachable: true),
            configuration: MockViewModelConfiguration()
        )
        let deepLinkURL = URL(string: "https://example.com/deep-link")!

        viewModel.openDeepLink(url: deepLinkURL)
        viewModel.start()
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(viewModel.state, .noInternet)
    }

    func testOpenDeepLinkPrioritizingStartupImmediatelySetsWebState() async {
        let viewModel = AppViewModel(
            initializeAppUseCase: MockAppInitializerUseCase(resultState: .native),
            pushTokenProvider: MockPushTokenProvider(token: "push-token"),
            networkConnectivityChecker: FixedConnectivityChecker(isReachable: false),
            configuration: MockViewModelConfiguration()
        )
        let deepLinkURL = URL(string: "https://example.com/startup-push")!

        viewModel.openDeepLinkPrioritizingStartup(url: deepLinkURL)

        XCTAssertEqual(viewModel.state, .web(deepLinkURL))
    }

    func testForceOpenTestStateRequiresDebugEnabled() async {
        let diagnostics = StartupDiagnostics(
            firebase: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: nil),
            appsFlyer: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: nil),
            serverRequest: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: nil),
            finalState: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: ".web"),
            more: StartupMoreData(firebaseData: "{}", appsFlyerData: "{}", serverRequestData: "{}", serverResponseData: "{}")
        )
        let useCase = MockAppInitializerUseCase(resultState: .web(URL(string: "https://example.com")!), diagnostics: diagnostics)
        let viewModel = AppViewModel(
            initializeAppUseCase: useCase,
            pushTokenProvider: MockPushTokenProvider(token: "push-token"),
            networkConnectivityChecker: FixedConnectivityChecker(isReachable: true),
            configuration: MockViewModelConfiguration(isDebug: false, isForceOpenTestState: true)
        )

        viewModel.start()
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(viewModel.state, .web(URL(string: "https://example.com")!))
    }

    func testForceOpenTestStateInDebugMapsResolvedStateToDiagnostics() async {
        let diagnostics = StartupDiagnostics(
            firebase: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: nil),
            appsFlyer: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: nil),
            serverRequest: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: nil),
            finalState: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: ".web"),
            more: StartupMoreData(firebaseData: "{}", appsFlyerData: "{}", serverRequestData: "{}", serverResponseData: "{}")
        )
        let useCase = MockAppInitializerUseCase(resultState: .web(URL(string: "https://example.com")!), diagnostics: diagnostics)
        let viewModel = AppViewModel(
            initializeAppUseCase: useCase,
            pushTokenProvider: MockPushTokenProvider(token: "push-token"),
            networkConnectivityChecker: FixedConnectivityChecker(isReachable: true),
            configuration: MockViewModelConfiguration(isDebug: true, isForceOpenTestState: true)
        )

        viewModel.start()
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(viewModel.state, .testState(diagnostics))
    }

    func testInfinityLoadingDoesNotMapToTestStateAfterDiagnosticsTimeout() async {
        let diagnostics = StartupDiagnostics(
            firebase: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: nil),
            appsFlyer: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: nil),
            serverRequest: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: nil),
            finalState: StartupDiagnosticStage(status: .ok, summary: "ok", targetState: ".loading"),
            more: StartupMoreData(firebaseData: "{}", appsFlyerData: "{}", serverRequestData: "{}", serverResponseData: "{}")
        )
        let useCase = MockAppInitializerUseCase(resultState: .loading, diagnostics: diagnostics)
        let viewModel = AppViewModel(
            initializeAppUseCase: useCase,
            pushTokenProvider: MockPushTokenProvider(token: "push-token"),
            networkConnectivityChecker: FixedConnectivityChecker(isReachable: true),
            configuration: MockViewModelConfiguration(isInfinityLoading: true)
        )

        viewModel.start()
        // Wait longer than diagnostics timeout to ensure loading is preserved.
        try? await Task.sleep(nanoseconds: 11_500_000_000)

        XCTAssertEqual(viewModel.state, .loading)
    }
}

private final class MockAppInitializerUseCase: AppInitializerUseCaseProtocol {
    var latestDiagnostics: StartupDiagnostics
    private let resultState: AppState

    init(resultState: AppState, diagnostics: StartupDiagnostics = .empty) {
        self.resultState = resultState
        self.latestDiagnostics = diagnostics
    }

    func execute(pushToken: String?, hasLaunchedBefore: Bool) async -> AppState {
        resultState
    }
}

private final class MockPushTokenProvider: PushTokenProviderProtocol {
    private let token: String?

    init(token: String?) {
        self.token = token
    }

    func getToken() async -> String? {
        token
    }
}

private struct FixedConnectivityChecker: NetworkConnectivityCheckingProtocol {
    let isReachable: Bool

    func isNetworkReachable() async -> Bool {
        isReachable
    }
}

private final class MockViewModelConfiguration: AppConfigurationProtocol {
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
    let isGameOnly: Bool = false
    let isWebOnly: Bool = false
    let isNoNetwork: Bool = false
    let isAskNotifications: Bool = false
    let isInfinityLoading: Bool
    let isForceOpenTestState: Bool

    init(isDebug: Bool = false, isInfinityLoading: Bool = false, isForceOpenTestState: Bool = false) {
        self.isDebug = isDebug
        self.isInfinityLoading = isInfinityLoading
        self.isForceOpenTestState = isForceOpenTestState
    }
}
