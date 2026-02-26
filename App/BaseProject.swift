import SwiftUI

/// Holds the app view model built from the launch container. Created once when BaseProject initializes.
@MainActor
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
/// so BaseProject can read it once to build the view model and inject into the hierarchy. No global singleton.
@main
@MainActor
struct BaseProject: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
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
                .onAppear {
                    holder.viewModel.start()
                    appDelegate.triggerTrackingAuthorizationFlowIfNeeded()
                }
                .onChange(of: scenePhase) { newPhase in
                    guard newPhase == .active else { return }
                    appDelegate.triggerTrackingAuthorizationFlowIfNeeded()
                }
        }
    }
}
