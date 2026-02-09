import Foundation
import SwiftUI

/// ViewModel for the password generator screen. Manages options and generation/copy.
@MainActor
final class PasswordGeneratorViewModel: ObservableObject {

    private let generatePasswordUseCase: GeneratePasswordUseCaseProtocol

    @Published var useUppercase = true
    @Published var useLowercase = true
    @Published var useNumbers = true
    @Published var useSymbols = false
    @Published var length: Double = 16
    @Published var generatedPassword: String = ""
    @Published var copiedMessage: String? = nil

    init(generatePasswordUseCase: GeneratePasswordUseCaseProtocol) {
        self.generatePasswordUseCase = generatePasswordUseCase
    }

    var lengthInt: Int { Int(length) }

    /// Generates password and copies it to the pasteboard. Shows brief "Copied" feedback.
    func generateAndCopy() {
        let params = GeneratePasswordParameters(
            useUppercase: useUppercase,
            useLowercase: useLowercase,
            useNumbers: useNumbers,
            useSymbols: useSymbols,
            length: lengthInt
        )
        guard let password = generatePasswordUseCase.execute(parameters: params) else { return }
        generatedPassword = password
        UIPasteboard.general.string = password
        copiedMessage = "Copied"
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            copiedMessage = nil
        }
    }

    var canGenerate: Bool {
        useUppercase || useLowercase || useNumbers || useSymbols
    }
}
