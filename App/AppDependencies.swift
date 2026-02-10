import Foundation

/// Factory for the application dependency container. The container is created once in AppDelegate at launch,
/// then passed into BaseProject and the view hierarchy via environment. No global singleton.
///
/// Tests can inject a mock by setting `containerForTesting` before the app runs; AppDelegate uses it in didFinishLaunching.
enum AppDependencies {

    /// If set (e.g. in tests), AppDelegate uses this instead of building a new container. Set before app launch.
    static var containerForTesting: DependencyContainer?

    /// Set by AppDelegate in didFinishLaunching so BaseProject can read it once to build the view model. Not a global getter.
    static var launchContainer: DependencyContainer? { _launchContainer }
    private static weak var _launchContainer: DependencyContainer?

    /// Called by AppDelegate after creating the container. Do not use from app code; only BaseProject reads launchContainer.
    static func setLaunchContainer(_ c: DependencyContainer?) {
        _launchContainer = c
    }

    /// Builds the default production container. Called by AppDelegate at launch (or containerForTesting is used).
    static func makeDefaultContainer() -> DependencyContainer {
        let buildConfig = BuildConfiguration.current
        let configuration = AppConfiguration(isDebug: buildConfig.isDebug)
        let logStorage = LogStore()
        let logger = DefaultLogger(storage: logStorage)
        let conversionDataLocalDataSource = ConversionDataLocalDataSource(logger: logger)
        let fcmTokenLocalDataSource = FCMTokenLocalDataSource()
        let analyticsRepository = AppsFlyerRepository(conversionDataSink: conversionDataLocalDataSource, logger: logger)
        let networkRepository = ServerAPIRepository(configuration: configuration, logger: logger)
        let conversionDataRepository = ConversionDataRepository(conversionDataSource: conversionDataLocalDataSource)
        let fetchConversionDataUseCase = FetchConversionDataUseCase(conversionDataRepository: conversionDataRepository)
        let initializeAppUseCase = InitializeAppUseCase(
            configuration: configuration,
            fetchConversionDataUseCase: fetchConversionDataUseCase,
            analyticsRepository: analyticsRepository,
            networkRepository: networkRepository
        )
        let pushTokenProvider = FCMTokenProvider(fcmTokenDataSource: fcmTokenLocalDataSource)
        return DefaultDependencyContainer(
            configuration: configuration,
            analyticsRepository: analyticsRepository,
            networkRepository: networkRepository,
            conversionDataRepository: conversionDataRepository,
            fcmTokenDataSource: fcmTokenLocalDataSource,
            initializeAppUseCase: initializeAppUseCase,
            pushTokenProvider: pushTokenProvider,
            logger: logger,
            logStorage: logStorage
        )
    }
}
