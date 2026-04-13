import SwiftUI

/// Main native shell placeholder. Extend with your tabs and content in the host app.
/// Layout follows the same fullscreen discipline as IOS-RoosterVault (GeometryReader, explicit
/// background frames, Spacer-based centering). Theme colors/gradients come from the design pass.
struct MainTabView: View {
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                Color(.systemGroupedBackground)
                    .frame(width: w, height: h)
                    .clipped()

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)
                        VStack(spacing: 12) {
                            Text("Native shell")
                                .font(.title)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: min(w * 0.88, 420))
                        Spacer(minLength: 0)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: w, height: h)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
