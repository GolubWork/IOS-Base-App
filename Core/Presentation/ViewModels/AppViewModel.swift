import Foundation
import Combine
import SwiftUI

private let hasLaunchedBeforeKey = "HasLaunchedBefore"

/// Coordinates application startup flow by delegating to app initializer use case.
/// Depends only on Domain protocols (AppInitializerUseCaseProtocol, PushTokenProviderProtocol).
@MainActor
final class AppViewModel: ObservableObject {

    private let initializeAppUseCase: AppInitializerUseCaseProtocol
    private let pushTokenProvider: PushTokenProviderProtocol

    init(
        initializeAppUseCase: AppInitializerUseCaseProtocol,
        pushTokenProvider: PushTokenProviderProtocol
    ) {
        self.initializeAppUseCase = initializeAppUseCase
        self.pushTokenProvider = pushTokenProvider
    }

    /// Current application state used to drive UI navigation.
    @Published var state: AppState = .loading

    /// Starts the application initialization flow and updates state from the use case result.
    func start() {
        Task { @MainActor in
            state = .loading
            try? await Task.sleep(nanoseconds: 150_000_000)

            let pushToken = await pushTokenProvider.getToken()
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey)

            let newState = await initializeAppUseCase.execute(
                pushToken: pushToken,
                hasLaunchedBefore: hasLaunchedBefore
            )

            if case .firstLaunch = newState {
                UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
            }

            state = newState
        }
    }
}
