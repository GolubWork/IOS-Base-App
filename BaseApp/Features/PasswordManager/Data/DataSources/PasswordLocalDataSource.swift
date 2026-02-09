import Foundation

/// UserDefaults key for storing saved passwords as JSON.
private let savedPasswordsKey = "SavedPasswords"

/// Local data source for passwords using UserDefaults (JSON array).
final class PasswordLocalDataSource {

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Reads all passwords from storage, newest first.
    func loadPasswords() throws -> [Password] {
        guard let data = defaults.data(forKey: savedPasswordsKey) else { return [] }
        let list = try decoder.decode([Password].self, from: data)
        return list.sorted { $0.createdAt > $1.createdAt }
    }

    /// Overwrites storage with the given passwords.
    func savePasswords(_ passwords: [Password]) throws {
        let data = try encoder.encode(passwords)
        defaults.set(data, forKey: savedPasswordsKey)
    }
}
