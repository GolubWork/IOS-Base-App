import Foundation

/// Repository that provides conversion data from local storage, waiting up to a timeout.
/// Implements ConversionDataRepositoryProtocol for use by FetchConversionDataUseCase.
final class ConversionDataRepository: ConversionDataRepositoryProtocol {

    private let conversionDataSource: ConversionDataSourceProtocol

    init(conversionDataSource: ConversionDataSourceProtocol) {
        self.conversionDataSource = conversionDataSource
    }

    func getConversionData(timeout: TimeInterval) async -> [AnyHashable: Any] {
        let start = Date()
        while conversionDataSource.conversionData == nil {
            try? await Task.sleep(nanoseconds: 200_000_000)
            if Date().timeIntervalSince(start) > timeout { break }
        }
        return conversionDataSource.conversionData ?? [:]
    }
}
