import Foundation

/// Protocol for saving a password entry.
protocol SavePasswordUseCaseProtocol: AnyObject {

    /// Saves the given password (url/name, password, note).
    func execute(urlOrName: String, password: String, note: String) async throws
}
