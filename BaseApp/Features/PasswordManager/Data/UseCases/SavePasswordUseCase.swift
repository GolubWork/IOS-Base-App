import Foundation

/// Use case: save a new password entry (url/name, password, note).
final class SavePasswordUseCase: SavePasswordUseCaseProtocol {

    private let repository: PasswordRepositoryProtocol

    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }

    func execute(urlOrName: String, password: String, note: String) async throws {
        let entry = Password(urlOrName: urlOrName, password: password, note: note)
        try await repository.save(entry)
    }
}
