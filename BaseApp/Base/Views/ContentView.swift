import SwiftUI

/// <summary>
/// Main content view that switches between different screens based on the application's state.
/// </summary>
struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingView()
            case .game:
                GameWindow()
            case .web(let url):
                WebWindow(url: url)
            case .firstLaunch(let url):
                FirstLaunchScreen(url: url)
            case .askNotifications(let url):
                FirstLaunchScreen(url: url)
            case .error(let message):
                Text("Error: \(message)").foregroundColor(.red)
            case .noInternet:
                NoInternetScreen(retryAction: { viewModel.start() })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { viewModel.start() }
    }
}
