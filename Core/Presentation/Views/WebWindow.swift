import SwiftUI

/// Fullscreen wrapper view for displaying web content using WebViewScreen.
struct WebWindow: View {
    /// URL to display in the web window.
    let url: URL

    var body: some View {
        WebViewScreen(url: url)
            .ignoresSafeArea()
    }
}
