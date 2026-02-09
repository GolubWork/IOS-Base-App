import Foundation

/// Character sets for password generation.
private let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
private let lowercase = "abcdefghijklmnopqrstuvwxyz"
private let numbers = "0123456789"
private let symbols = "!@#$%^&*()_+-=[]{}|;:',.<>?"

/// Use case: generate a random password from enabled character sets and length.
final class GeneratePasswordUseCase: GeneratePasswordUseCaseProtocol {

    func execute(parameters: GeneratePasswordParameters) -> String? {
        guard parameters.isValid else { return nil }
        var pool: [Character] = []
        if parameters.useUppercase { pool += uppercase }
        if parameters.useLowercase { pool += lowercase }
        if parameters.useNumbers { pool += numbers }
        if parameters.useSymbols { pool += symbols }
        guard !pool.isEmpty else { return nil }
        let length = min(32, max(4, parameters.length))
        return (0..<length).map { _ in pool.randomElement()! }.map(String.init).joined()
    }
}
