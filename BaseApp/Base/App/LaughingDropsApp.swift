import SwiftUI

/// <summary>
/// Main application entry point. Initializes the app delegate, view models,
/// and launches the root view with necessary environment objects.
/// </summary>
@main
struct LaughingDropsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appVM = AppViewModel()
    @StateObject var history = HistoryStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appVM)
                .environmentObject(history)
                .onAppear {
                    appVM.start()
                }
        }
    }
}

/// <summary>
/// Root view that switches between different screens based on the application's state.
/// </summary>
struct RootView: View {
    @EnvironmentObject var appVM: AppViewModel

    var body: some View {
        Group {
            switch appVM.state {
            case .loading:
                LoadingView()
            case .firstLaunch(let url):
                FirstLaunchScreen(url: url)
            case .game:
                MainTabView()
            case .web(let url):
                WebWindow(url: url)
            case .error(let msg):
                Text("Error: \(msg)")
                    .foregroundColor(.red)
            case .askNotifications(let url):
                FirstLaunchScreen(url: url)
            case .noInternet:
                NoInternetScreen(retryAction: {
                    appVM.start()
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
