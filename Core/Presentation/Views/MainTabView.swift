import SwiftUI

/// Main native shell placeholder. Extend with your tabs and content in the host app.
/// Uses a neutral system background only. Brand assets such as `gameBackground` are filled by the
/// design/theme agent pass; this template does not draw them until that integration is added.
struct MainTabView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            Text("Native shell")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
}
