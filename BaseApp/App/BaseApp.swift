import SwiftUI

/// Holds the app view model built from the launch container. Created once when BaseApp initializes.
private final class AppViewModelHolder: ObservableObject {
    let container: DependencyContainer
    lazy var viewModel: AppViewModel = AppViewModel(
        initializeAppUseCase: container.initializeAppUseCase,
        pushTokenProvider: container.pushTokenProvider
    )
    init(container: DependencyContainer) {
        self.container = container
    }
}

/// Main application entry point. AppDelegate creates the dependency container at launch and assigns it
/// so BaseApp can read it once to build the view model and inject into the hierarchy. No global singleton.
@main
struct BaseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var holder: AppViewModelHolder

    init() {
        // Container is set in AppDelegate.didFinishLaunching, which runs before SwiftUI creates the App.
        _holder = StateObject(wrappedValue: AppViewModelHolder(container: AppDependencies.launchContainer!))
    }

    var body: some Scene {
        let container = appDelegate.container
        return WindowGroup {
            RootView()
                .environment(\.dependencyContainer, container)
                .environmentObject(holder.viewModel)
                .onAppear { holder.viewModel.start() }
        }
    }
}
