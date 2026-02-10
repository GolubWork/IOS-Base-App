import Foundation

/// Protocol for fetching conversion data. Used by initialization flow and tests.
protocol FetchConversionDataUseCaseProtocol: AnyObject {

    /// Fetches conversion data, waiting up to the given timeout.
    /// - Parameter timeout: Maximum wait time in seconds.
    /// - Returns: Conversion data dictionary (e.g. from AppsFlyer); may be empty on timeout.
    func execute(timeout: TimeInterval) async -> [AnyHashable: Any]
}

/// Use case: obtain attribution/conversion data (e.g. from AppsFlyer) with optional timeout.
final class FetchConversionDataUseCase: FetchConversionDataUseCaseProtocol {

    private let conversionDataRepository: ConversionDataRepositoryProtocol

    init(conversionDataRepository: ConversionDataRepositoryProtocol) {
        self.conversionDataRepository = conversionDataRepository
    }

    func execute(timeout: TimeInterval) async -> [AnyHashable: Any] {
        await conversionDataRepository.getConversionData(timeout: timeout)
    }
}
