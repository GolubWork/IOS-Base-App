import SwiftUI

/// Root view that switches between different screens based on the application's state.
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
