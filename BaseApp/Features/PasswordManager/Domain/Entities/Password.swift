import Foundation

/// Domain entity for a saved password entry (url/name, password, note, createdAt).
struct Password: Codable, Identifiable, Equatable {
    let id: UUID
    var urlOrName: String
    var password: String
    var note: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        urlOrName: String,
        password: String,
        note: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.urlOrName = urlOrName
        self.password = password
        self.note = note
        self.createdAt = createdAt
    }
}
