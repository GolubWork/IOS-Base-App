import Foundation

/// Protocol for retrieving all saved passwords.
protocol GetPasswordsUseCaseProtocol: AnyObject {

    /// Returns all saved passwords, ordered by creation date (newest first).
    func execute() async throws -> [Password]
}
