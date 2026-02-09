import Foundation
import SwiftUI

/// ViewModel for the save-password screen. Handles URL/name, password, note and save action.
@MainActor
final class PasswordSaveViewModel: ObservableObject {

    private let savePasswordUseCase: SavePasswordUseCaseProtocol

    @Published var urlOrName: String = ""
    @Published var password: String = ""
    @Published var note: String = ""
    @Published var isSaving = false
    @Published var saveMessage: String? = nil
    @Published var saveError: String? = nil

    init(savePasswordUseCase: SavePasswordUseCaseProtocol) {
        self.savePasswordUseCase = savePasswordUseCase
    }

    var canSave: Bool {
        !urlOrName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty
    }

    /// Saves the current fields and clears on success (or shows error).
    func save() {
        let url = urlOrName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !url.isEmpty, !password.isEmpty else { return }
        isSaving = true
        saveError = nil
        saveMessage = nil
        Task { @MainActor in
            do {
                try await savePasswordUseCase.execute(urlOrName: url, password: password, note: note)
                saveMessage = "Saved"
                urlOrName = ""
                password = ""
                note = ""
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                saveMessage = nil
            } catch {
                saveError = error.localizedDescription
            }
            isSaving = false
        }
    }
}
