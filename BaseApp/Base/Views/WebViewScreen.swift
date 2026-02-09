import SwiftUI
import WebKit

/// <summary>
/// SwiftUI wrapper for displaying web content using WKWebView with custom navigation handling.
/// Handles too many redirects, disables zoom, and opens target="_blank" links in the same view.
/// </summary>
struct WebViewScreen: UIViewRepresentable {
    /// <summary>
    /// URL to load in the web view.
    /// </summary>
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(initialURL: url)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    /// <summary>
    /// Coordinator to handle WKWebView navigation delegate methods.
    /// </summary>
    class Coordinator: NSObject, WKNavigationDelegate {
        let initialURL: URL

        init(initialURL: URL) {
            self.initialURL = initialURL
        }

        /// <summary>
        /// Handles error -1007 (too many redirects) by reloading the last known URL.
        /// </summary>
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {

            let nsError = error as NSError

            if nsError.domain == NSURLErrorDomain &&
                nsError.code == NSURLErrorHTTPTooManyRedirects {

                print("⚠️ Too many redirects, reloading last known URL…")

                let failingURL = nsError.userInfo[NSURLErrorFailingURLErrorKey] as? URL
                let reloadURL = failingURL ?? initialURL

                webView.load(URLRequest(url: reloadURL))
            }
        }

        /// <summary>
        /// Injects meta viewport to disable zoom after page finishes loading.
        /// </summary>
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let js = """
            var meta = document.querySelector('meta[name=viewport]');
            if (!meta) {
                meta = document.createElement('meta');
                meta.name = 'viewport';
                document.head.appendChild(meta);
            }
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }

        /// <summary>
        /// Forces links with target="_blank" to open in the same web view.
        /// </summary>
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {

            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
