import Foundation

/// Protocol for the application dependency container. Provides access to configuration,
/// repositories, use cases, logging, and local data sources. Use this protocol in views/view models for testability.
/// Tests can substitute the container via `AppDependencies.containerForTesting` set before app launch.
protocol DependencyContainer: AnyObject {
    var configuration: AppConfigurationProtocol { get }
    var analyticsRepository: AnalyticsRepositoryProtocol { get }
    var networkRepository: NetworkRepositoryProtocol { get }
    var conversionDataRepository: ConversionDataRepositoryProtocol { get }
    var fcmTokenDataSource: FCMTokenDataSourceProtocol { get }
    var initializeAppUseCase: AppInitializerUseCaseProtocol { get }
    var pushTokenProvider: PushTokenProviderProtocol { get }
    var logger: Logging { get }
    var logStorage: LogStorageProtocol { get }
    var passwordRepository: PasswordRepositoryProtocol { get }
    var generatePasswordUseCase: GeneratePasswordUseCaseProtocol { get }
    var savePasswordUseCase: SavePasswordUseCaseProtocol { get }
    var getPasswordsUseCase: GetPasswordsUseCaseProtocol { get }
}

/// Default implementation of the dependency container. Holds references to injected dependencies.
final class DefaultDependencyContainer: DependencyContainer {

    private(set) var configuration: AppConfigurationProtocol
    private(set) var analyticsRepository: AnalyticsRepositoryProtocol
    private(set) var networkRepository: NetworkRepositoryProtocol
    private(set) var conversionDataRepository: ConversionDataRepositoryProtocol
    private(set) var fcmTokenDataSource: FCMTokenDataSourceProtocol
    private(set) var initializeAppUseCase: AppInitializerUseCaseProtocol
    private(set) var pushTokenProvider: PushTokenProviderProtocol
    private(set) var logger: Logging
    private(set) var logStorage: LogStorageProtocol
    private(set) var passwordRepository: PasswordRepositoryProtocol
    private(set) var generatePasswordUseCase: GeneratePasswordUseCaseProtocol
    private(set) var savePasswordUseCase: SavePasswordUseCaseProtocol
    private(set) var getPasswordsUseCase: GetPasswordsUseCaseProtocol

    /// Creates a container with the given dependencies.
    init(
        configuration: AppConfigurationProtocol,
        analyticsRepository: AnalyticsRepositoryProtocol,
        networkRepository: NetworkRepositoryProtocol,
        conversionDataRepository: ConversionDataRepositoryProtocol,
        fcmTokenDataSource: FCMTokenDataSourceProtocol,
        initializeAppUseCase: AppInitializerUseCaseProtocol,
        pushTokenProvider: PushTokenProviderProtocol,
        logger: Logging,
        logStorage: LogStorageProtocol,
        passwordRepository: PasswordRepositoryProtocol,
        generatePasswordUseCase: GeneratePasswordUseCaseProtocol,
        savePasswordUseCase: SavePasswordUseCaseProtocol,
        getPasswordsUseCase: GetPasswordsUseCaseProtocol
    ) {
        self.configuration = configuration
        self.analyticsRepository = analyticsRepository
        self.networkRepository = networkRepository
        self.conversionDataRepository = conversionDataRepository
        self.fcmTokenDataSource = fcmTokenDataSource
        self.initializeAppUseCase = initializeAppUseCase
        self.pushTokenProvider = pushTokenProvider
        self.logger = logger
        self.logStorage = logStorage
        self.passwordRepository = passwordRepository
        self.generatePasswordUseCase = generatePasswordUseCase
        self.savePasswordUseCase = savePasswordUseCase
        self.getPasswordsUseCase = getPasswordsUseCase
    }
}
