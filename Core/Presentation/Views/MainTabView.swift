import SwiftUI

/// Main view shown in game mode. Placeholder for your content.
/// Game background is drawn inside this view (and in each tab screen when you add tabs).
struct MainTabView: View {
    var body: some View {
        ZStack {
            Image("gameBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.container, edges: .all)

            Text("Game Mode")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
}
