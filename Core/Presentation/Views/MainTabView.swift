import SwiftUI

/// Main native shell placeholder. Extend with your tabs and content in the host app.
/// Layout follows the same fullscreen discipline as IOS-RoosterVault (GeometryReader, explicit
/// background frames, Spacer-based centering). Theme colors/gradients come from the design pass.
struct MainTabView: View {
    @Environment(\.dependencyContainer) private var dependencyContainer
    @StateObject private var fallbackTimerSessionStore = InMemoryTimerSessionStore()

    var body: some View {
        let timerSessionStore = dependencyContainer?.timerSessionStore ?? fallbackTimerSessionStore
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                GameThemePalette.skyBackgroundGradient
                    .frame(width: w, height: h)
                    .clipped()

                TabView {
                    NavigationStack {
                        TimerScreen(viewModel: TimerViewModel(timerSessionStore: timerSessionStore))
                    }
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }

                    NavigationStack {
                        HistoryScreen(viewModel: HistoryViewModel(timerSessionStore: timerSessionStore))
                    }
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                }
                .tint(GameThemePalette.chickenGoldenYellow)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(GameThemePalette.chickenSkyTop.opacity(0.92), for: .tabBar)
                .toolbarColorScheme(.dark, for: .tabBar)
            }
            .frame(width: w, height: h)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
