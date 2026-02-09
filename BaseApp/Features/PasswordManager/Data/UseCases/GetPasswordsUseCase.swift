import Foundation

/// Use case: retrieve all saved passwords.
final class GetPasswordsUseCase: GetPasswordsUseCaseProtocol {

    private let repository: PasswordRepositoryProtocol

    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Password] {
        try await repository.getAll()
    }
}
