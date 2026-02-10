import SwiftUI

/// Screen displayed when there is no internet connection,
/// showing a message and allowing the user to retry.
struct NoInternetScreen: View {
    /// Action to perform when the user wants to retry the connection.
    let retryAction: () -> Void
    @Environment(\.dependencyContainer) private var container

    private var message: String {
        container?.configuration.noInternetMessage ?? "Please check your internet connection."
    }

    var body: some View {
        ZStack {
            Image("internetBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()

                ZStack {
                    if UIImage(named: "frame") != nil {
                        Image("frame")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 420))
                            .overlay(
                                VStack(spacing: 16) {
                                    Image(systemName: "wifi.slash")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.red)

                                    Text(message)
                                        .multilineTextAlignment(.center)
                                        .font(.title3)
                                        .padding(.horizontal, 20)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 24)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.95))
                            .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 420))
                            .shadow(radius: 10)
                            .overlay(
                                VStack(spacing: 16) {
                                    Image(systemName: "wifi.slash")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.red)

                                    Text(message)
                                        .multilineTextAlignment(.center)
                                        .font(.title3)
                                        .padding(.horizontal, 20)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 24)
                            )
                    }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .contain)

                Spacer()
            }
            .padding()
        }
    }
}
