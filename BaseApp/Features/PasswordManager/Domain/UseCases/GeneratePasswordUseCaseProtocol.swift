import Foundation

/// Parameters for password generation (character sets and length).
struct GeneratePasswordParameters {
    var useUppercase: Bool
    var useLowercase: Bool
    var useNumbers: Bool
    var useSymbols: Bool
    var length: Int

    /// At least one character set must be enabled for valid generation.
    var isValid: Bool {
        (useUppercase || useLowercase || useNumbers || useSymbols) && length >= 4 && length <= 32
    }
}

/// Protocol for generating a random password from given parameters.
protocol GeneratePasswordUseCaseProtocol: AnyObject {

    /// Generates a password using the specified parameters.
    /// - Parameter parameters: Character sets and length (4–32). At least one set must be enabled.
    /// - Returns: Generated password string, or nil if parameters are invalid.
    func execute(parameters: GeneratePasswordParameters) -> String?
}
