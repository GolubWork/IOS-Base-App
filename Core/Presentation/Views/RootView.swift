import SwiftUI
import UIKit

/// Root view that switches between different screens based on the application's state.
struct RootView: View {
    @EnvironmentObject var appVM: AppViewModel

    var body: some View {
        Group {
            switch appVM.state {
            case .loading:
                LoadingView()
            case .firstLaunch(let url):
                FirstLaunchScreen(url: url, isAskNotificationsMode: false)
            case .native:
                MainTabView()
            case .testState(let diagnostics):
                TestStateView(diagnostics: diagnostics)
            case .web(let url):
                WebWindow(url: url)
            case .error(let msg):
                GeometryReader { geometry in
                    let w = geometry.size.width
                    let h = geometry.size.height
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            Text("Error: \(msg)")
                                .font(AppTypography.body)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: min(w * 0.9, 400))
                            Spacer(minLength: 0)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(width: w, height: h)
                }
            case .askNotifications(let url):
                FirstLaunchScreen(url: url, isAskNotificationsMode: true)
            case .noInternet:
                NoInternetScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            applyOrientationLock(for: appVM.state)
        }
        .onChange(of: appVM.state) { newState in
            applyOrientationLock(for: newState)
        }
    }

    private func applyOrientationLock(for state: AppState) {
        let lock: UIInterfaceOrientationMask
        switch state {
        case .native:
            lock = .portrait
        default:
            lock = .allButUpsideDown
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.updateOrientationLock(lock)
    }
}
