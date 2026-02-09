import SwiftUI

/// <summary>
/// Fullscreen wrapper view for displaying web content using WebViewScreen.
/// </summary>
struct WebWindow: View {
    /// <summary>
    /// URL to display in the web window.
    /// </summary>
    let url: URL
    
    var body: some View {
        WebViewScreen(url: url)
            .ignoresSafeArea()
    }
}
