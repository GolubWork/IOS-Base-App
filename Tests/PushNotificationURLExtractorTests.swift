import XCTest
@testable import BaseProject

final class PushNotificationURLExtractorTests: XCTestCase {

    func testFirstURLStringPrefersUrlOverLink() {
        let userInfo: [AnyHashable: Any] = [
            "link": "https://example.com/wrong",
            "url": "https://example.com/right"
        ]
        XCTAssertEqual(PushNotificationURLExtractor.firstURLString(from: userInfo), "https://example.com/right")
    }

    func testUrlForDeepLinkRoutingReturnsURL() {
        let userInfo: [AnyHashable: Any] = ["url": "https://example.com/promo"]
        XCTAssertEqual(
            PushNotificationURLExtractor.urlForDeepLinkRouting(from: userInfo),
            URL(string: "https://example.com/promo")
        )
    }

    func testUrlForDeepLinkRoutingSkipsUnresolvableCandidateAndUsesNextValidURL() {
        let userInfo: [AnyHashable: Any] = [
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "gcm.notification": ["link": "https://example.com/from-gcm"]
        ]
        XCTAssertEqual(
            PushNotificationURLExtractor.urlForDeepLinkRouting(from: userInfo),
            URL(string: "https://example.com/from-gcm")
        )
    }

    func testNestedGcmNotificationLink() {
        let userInfo: [AnyHashable: Any] = [
            "gcm.notification": ["link": "https://example.com/from-gcm"]
        ]
        XCTAssertEqual(
            PushNotificationURLExtractor.firstURLString(from: userInfo),
            "https://example.com/from-gcm"
        )
    }
}
