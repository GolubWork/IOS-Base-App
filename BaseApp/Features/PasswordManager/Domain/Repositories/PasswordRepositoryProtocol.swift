import Foundation

/// Protocol for persisting and retrieving passwords. Allows swapping implementations for tests.
protocol PasswordRepositoryProtocol: AnyObject {

    /// Saves a password entry. Replaces existing entry with the same id if present.
    func save(_ password: Password) async throws

    /// Returns all saved passwords, ordered by creation date (newest first).
    func getAll() async throws -> [Password]

    /// Deletes the password with the given id.
    func delete(id: UUID) async throws
}
