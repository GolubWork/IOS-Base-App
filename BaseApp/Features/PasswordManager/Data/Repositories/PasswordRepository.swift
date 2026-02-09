import Foundation

/// Repository implementation that persists passwords via PasswordLocalDataSource.
final class PasswordRepository: PasswordRepositoryProtocol {

    private let dataSource: PasswordLocalDataSource

    init(dataSource: PasswordLocalDataSource) {
        self.dataSource = dataSource
    }

    func save(_ password: Password) async throws {
        var list = try dataSource.loadPasswords()
        if let idx = list.firstIndex(where: { $0.id == password.id }) {
            list[idx] = password
        } else {
            list.append(password)
        }
        try dataSource.savePasswords(list)
    }

    func getAll() async throws -> [Password] {
        try dataSource.loadPasswords()
    }

    func delete(id: UUID) async throws {
        var list = try dataSource.loadPasswords()
        list.removeAll { $0.id == id }
        try dataSource.savePasswords(list)
    }
}
