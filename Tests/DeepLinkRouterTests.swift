import XCTest
@testable import BaseProject

@MainActor
final class DeepLinkRouterTests: XCTestCase {

    func testHandleIncomingURLAcceptsHTTPURL() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "https://example.com/path")!

        router.handleIncomingURL(inputURL)

        XCTAssertEqual(router.pendingURL, inputURL)
    }

    func testHandleIncomingURLResolvesEmbeddedURLQueryItem() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "app://open?url=https://example.com/offer")!

        router.handleIncomingURL(inputURL)

        XCTAssertEqual(router.pendingURL, URL(string: "https://example.com/offer"))
    }

    func testHandleIncomingURLResolvesPercentEncodedEmbeddedURL() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "app://open?url=https%3A%2F%2Fexample.com%2Fpromo%3Fid%3D42")!

        router.handleIncomingURL(inputURL)

        XCTAssertEqual(router.pendingURL, URL(string: "https://example.com/promo?id=42"))
    }

    func testHandleIncomingURLResolvesEmbeddedWebURLFromPath() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "myapp:///open/https://example.com/path")!

        router.handleIncomingURL(inputURL)

        XCTAssertEqual(router.pendingURL, URL(string: "https://example.com/path"))
    }

    func testHandleIncomingURLResolvesWebURLFromNonStandardQueryKey() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "myapp://open?target=https%3A%2F%2Fexample.com%2Fdeep")!

        router.handleIncomingURL(inputURL)

        XCTAssertEqual(router.pendingURL, URL(string: "https://example.com/deep"))
    }

    func testHandleIncomingURLResolvesWebURLFromDeepLinkKey() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "myapp://open?deep_link=https%3A%2F%2Fexample.com%2Foffer")!

        router.handleIncomingURL(inputURL)

        XCTAssertEqual(router.pendingURL, URL(string: "https://example.com/offer"))
    }

    func testHandleIncomingURLResolvesWebURLFromRedirectKey() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "myapp://open?redirect=https%3A%2F%2Fexample.com%2Fcheckout")!

        router.handleIncomingURL(inputURL)

        XCTAssertEqual(router.pendingURL, URL(string: "https://example.com/checkout"))
    }

    func testHandleIncomingURLResolvesDoubleEncodedURL() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "myapp://open?url=https%253A%252F%252Fexample.com%252Fdouble")!

        router.handleIncomingURL(inputURL)

        XCTAssertEqual(router.pendingURL, URL(string: "https://example.com/double"))
    }

    func testResolveIncomingURLDetailedReturnsRejectedReasonForUnsupportedURL() {
        let inputURL = URL(string: "phonepe://upi/pay?pa=test")!
        let result = DeepLinkRouter.resolveIncomingURLDetailed(inputURL)

        guard case .rejected(let reason) = result else {
            return XCTFail("Expected rejected resolution result")
        }
        XCTAssertTrue(reason.contains("Unsupported deep link"))
    }

    func testHandleIncomingURLIgnoresUnsupportedURL() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "app://open?screen=promo")!

        router.handleIncomingURL(inputURL)

        XCTAssertNil(router.pendingURL)
    }

    func testHandleIncomingURLPrefersUrlOverLinkWhenBothPresent() {
        let router = DeepLinkRouter()
        let inputURL = URL(string: "myapp://open?link=https%3A%2F%2Fexample.com%2Fwrong&url=https%3A%2F%2Fexample.com%2Fright")!

        router.handleIncomingURL(inputURL)

        XCTAssertEqual(router.pendingURL, URL(string: "https://example.com/right"))
    }
}
