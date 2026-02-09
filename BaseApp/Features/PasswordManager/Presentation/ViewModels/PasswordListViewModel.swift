import Foundation
import SwiftUI

/// ViewModel for the password list screen. Loads passwords and handles copy on tap.
@MainActor
final class PasswordListViewModel: ObservableObject {

    private let getPasswordsUseCase: GetPasswordsUseCaseProtocol

    @Published var passwords: [Password] = []
    @Published var isLoading = false
    @Published var loadError: String? = nil
    @Published var copiedId: UUID? = nil

    init(getPasswordsUseCase: GetPasswordsUseCaseProtocol) {
        self.getPasswordsUseCase = getPasswordsUseCase
    }

    /// Reloads the list from storage.
    func load() {
        isLoading = true
        loadError = nil
        Task { @MainActor in
            do {
                passwords = try await getPasswordsUseCase.execute()
            } catch {
                loadError = error.localizedDescription
            }
            isLoading = false
        }
    }

    /// Copies the password to pasteboard and shows brief feedback for the given id.
    func copyPassword(_ password: Password) {
        UIPasteboard.general.string = password.password
        copiedId = password.id
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            copiedId = nil
        }
    }
}
