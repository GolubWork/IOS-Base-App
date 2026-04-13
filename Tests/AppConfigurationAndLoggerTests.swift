import XCTest
@testable import BaseProject

final class AppConfigurationAndLoggerTests: XCTestCase {

    func testFeatureFlagsAreAppliedEvenWhenDebugIsFalse() {
        let configuration = AppConfiguration(
            isDebug: false,
            isGameOnly: true,
            isWebOnly: true,
            isNoNetwork: true,
            isAskNotifications: true,
            isInfinityLoading: true
        )

        XCTAssertTrue(configuration.isGameOnly)
        XCTAssertTrue(configuration.isWebOnly)
        XCTAssertTrue(configuration.isNoNetwork)
        XCTAssertTrue(configuration.isAskNotifications)
        XCTAssertTrue(configuration.isInfinityLoading)
    }

    func testFeatureFlagsAreAppliedWhenDebugIsTrue() {
        let configuration = AppConfiguration(
            isDebug: true,
            isGameOnly: true,
            isWebOnly: true,
            isNoNetwork: true,
            isAskNotifications: true,
            isInfinityLoading: true
        )

        XCTAssertTrue(configuration.isGameOnly)
        XCTAssertTrue(configuration.isWebOnly)
        XCTAssertTrue(configuration.isNoNetwork)
        XCTAssertTrue(configuration.isAskNotifications)
        XCTAssertTrue(configuration.isInfinityLoading)
    }

    func testConfigUsesExplicitPlaceholderStringsWhenProvided() {
        let configuration = AppConfiguration(
            serverURL: "$(SERVER_URL)",
            storeId: "$(STORE_ID)",
            firebaseProjectId: "$(FIREBASE_PROJECT_ID)",
            appsFlyerDevKey: "$(APPSFLYER_DEV_KEY)"
        )

        XCTAssertEqual(configuration.serverURL, "$(SERVER_URL)")
        XCTAssertEqual(configuration.storeId, "$(STORE_ID)")
        XCTAssertEqual(configuration.firebaseProjectId, "$(FIREBASE_PROJECT_ID)")
        XCTAssertEqual(configuration.appsFlyerDevKey, "$(APPSFLYER_DEV_KEY)")
    }

    func testForceOpenTestStateDoesNotDependOnDebugFlag() {
        let configuration = AppConfiguration(
            isDebug: false,
            isForceOpenTestState: true
        )

        XCTAssertTrue(configuration.isForceOpenTestState)
    }

    func testForceOpenTestStateUsesDefaultValueWhenNotProvided() {
        let configuration = AppConfiguration(
            isDebug: false,
            isAskNotifications: false
        )

        XCTAssertFalse(configuration.isForceOpenTestState)
    }

    func testForceOpenTestStateCanBeDisabledExplicitly() {
        let configuration = AppConfiguration(
            isDebug: true,
            isForceOpenTestState: false
        )

        XCTAssertFalse(configuration.isForceOpenTestState)
    }

    func testLoggerDoesNotWriteWhenDisabled() {
        let storage = MemoryLogStorage()
        let logger = DefaultLogger(storage: storage, isEnabled: false)

        logger.log("must not be written", level: .info)

        XCTAssertTrue(storage.lines.isEmpty)
    }
}

private final class MemoryLogStorage: LogStorageProtocol {
    private(set) var lines: [String] = []

    func append(message: String) {
        lines.append(message)
    }
}
