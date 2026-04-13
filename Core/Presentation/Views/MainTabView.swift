import SwiftUI
import UIKit

/// Main native shell placeholder. Extend with your tabs and content in the host app.
/// Optional `gameBackground` asset: if missing, uses a system background.
struct MainTabView: View {
    var body: some View {
        ZStack {
            if UIImage(named: "gameBackground") != nil {
                Image("gameBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.container, edges: .all)
            } else {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            }

            Text("Native shell")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
}
