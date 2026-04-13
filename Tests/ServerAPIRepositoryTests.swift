import XCTest
@testable import BaseProject

final class ServerAPIRepositoryTests: XCTestCase {

    func testFetchConfigReturnsURLForOkResponse() async throws {
        let responseJSON = #"{"ok":true,"url":"https://example.com/path"}"#
        let logger = MockLogger()
        let session = MockNetworkSession(
            result: .success((
                Data(responseJSON.utf8),
                HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            ))
        )
        let repository = ServerAPIRepository(
            configuration: MockAppConfiguration(serverURL: "https://example.com/config"),
            logger: logger,
            session: session
        )

        let result = try await repository.fetchConfig(usingPayload: ["af_status": "Organic"], timeout: 1)

        XCTAssertEqual(result.urlString, "https://example.com/path")
        XCTAssertTrue(
            logger.messages.contains(where: { $0.contains("ServerAPI Request:") }),
            "Expected request logging for diagnostics"
        )
        XCTAssertTrue(
            logger.messages.contains(where: { $0.contains("ServerAPI Response: status=200") }),
            "Expected response status logging for diagnostics"
        )
        XCTAssertTrue(
            logger.messages.contains(where: { $0.contains("ServerAPI Parse: resolvedURL=https://example.com/path") }),
            "Expected resolved URL logging for diagnostics"
        )
    }

    func testFetchConfigReturnsURLForLinkFallbackWithoutSuccessFlag() async throws {
        let responseJSON = #"{"link":"https://example.com/link"}"#
        let session = MockNetworkSession(
            result: .success((
                Data(responseJSON.utf8),
                HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            ))
        )
        let repository = ServerAPIRepository(
            configuration: MockAppConfiguration(serverURL: "https://example.com/config"),
            logger: MockLogger(),
            session: session
        )

        let result = try await repository.fetchConfig(usingPayload: ["af_status": "Organic"], timeout: 1)

        XCTAssertEqual(result.urlString, "https://example.com/link")
    }

    func testFetchWebURLThrowsForNon2xxStatus() async {
        let responseJSON = #"{"ok":false}"#
        let logger = MockLogger()
        let session = MockNetworkSession(
            result: .success((
                Data(responseJSON.utf8),
                HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            ))
        )
        let repository = ServerAPIRepository(
            configuration: MockAppConfiguration(serverURL: "https://example.com/config"),
            logger: logger,
            session: session
        )

        do {
            _ = try await repository.fetchConfig(usingPayload: ["af_status": "Organic"], timeout: 1)
            XCTFail("Expected httpError")
        } catch let error as ServerAPIRepositoryError {
            guard case .httpError(let statusCode, _) = error else {
                return XCTFail("Unexpected error \(error)")
            }
            XCTAssertEqual(statusCode, 500)
            XCTAssertTrue(
                logger.messages.contains(where: { $0.contains("ServerAPI Error: non-success HTTP status 500") }),
                "Expected HTTP status error logging for diagnostics"
            )
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testFetchWebURLThrowsTimeout() async {
        let session = MockNetworkSession(
            result: .failure(MockError.generic),
            delayNanoseconds: 1_500_000_000
        )
        let repository = ServerAPIRepository(
            configuration: MockAppConfiguration(serverURL: "https://example.com/config"),
            logger: MockLogger(),
            session: session
        )

        do {
            _ = try await repository.fetchConfig(usingPayload: ["af_status": "Organic"], timeout: 0.1)
            XCTFail("Expected timeout error")
        } catch let error as ServerAPIRepositoryError {
            guard case .timeout = error else {
                return XCTFail("Unexpected error \(error)")
            }
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testFetchWebURLThrowsInvalidURL() async {
        let repository = ServerAPIRepository(
            configuration: MockAppConfiguration(serverURL: ""),
            logger: MockLogger(),
            session: MockNetworkSession(result: .failure(MockError.generic))
        )

        do {
            _ = try await repository.fetchConfig(usingPayload: ["af_status": "Organic"], timeout: 1)
            XCTFail("Expected invalidURL")
        } catch let error as ServerAPIRepositoryError {
            guard case .invalidURL = error else {
                return XCTFail("Unexpected error \(error)")
            }
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testFetchWebURLThrowsInvalidPayload() async {
        let session = MockNetworkSession(result: .failure(MockError.generic))
        let repository = ServerAPIRepository(
            configuration: MockAppConfiguration(serverURL: "https://example.com/config"),
            logger: MockLogger(),
            session: session
        )
        let invalidPayload: [AnyHashable: Any] = ["date": Date()]

        do {
            _ = try await repository.fetchConfig(usingPayload: invalidPayload, timeout: 1)
            XCTFail("Expected invalidPayload")
        } catch let error as ServerAPIRepositoryError {
            guard case .invalidPayload = error else {
                return XCTFail("Unexpected error \(error)")
            }
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testFetchConfigParsesExpiresAsUnixTimestamp() async throws {
        let responseJSON = #"{"ok":true,"url":"https://example.com/path","expires":1735689600}"#
        let session = MockNetworkSession(
            result: .success((
                Data(responseJSON.utf8),
                HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            ))
        )
        let repository = ServerAPIRepository(
            configuration: MockAppConfiguration(serverURL: "https://example.com/config"),
            logger: MockLogger(),
            session: session
        )

        let result = try await repository.fetchConfig(usingPayload: ["af_status": "Organic"], timeout: 1)

        XCTAssertEqual(result.urlString, "https://example.com/path")
        XCTAssertEqual(result.expiresAt, Date(timeIntervalSince1970: 1_735_689_600))
    }
}

private final class MockNetworkSession: NetworkSessionProtocol {
    private let result: Result<(Data, URLResponse), Error>
    private let delayNanoseconds: UInt64

    init(result: Result<(Data, URLResponse), Error>, delayNanoseconds: UInt64 = 0) {
        self.result = result
        self.delayNanoseconds = delayNanoseconds
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        switch result {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
}

private enum MockError: Error {
    case generic
}

private final class MockLogger: Logging {
    private(set) var messages: [String] = []

    func log(_ message: String, level: LogLevel) {
        messages.append(message)
    }
}

private final class MockAppConfiguration: AppConfigurationProtocol {
    let serverURL: String
    let storeId: String = "6759390373"
    let firebaseProjectId: String = "487557931280"
    let appsFlyerDevKey: String = "dev-key"
    var storeIdWithPrefix: String { "id\(storeId)" }
    let os: String = "iOS"
    let noInternetMessage: String = ""
    let notificationSubtitle: String = ""
    let notificationDescription: String = ""
    let isDebug: Bool = true
    let isGameOnly: Bool = false
    let isWebOnly: Bool = false
    let isNoNetwork: Bool = false
    let isAskNotifications: Bool = false
    let isInfinityLoading: Bool = false
    let isForceOpenTestState: Bool = false

    init(serverURL: String) {
        self.serverURL = serverURL
    }
}
