import SwiftUI

/// Screen for saving a password with URL/name, password, and note fields.
struct PasswordSaveView: View {
    @StateObject private var viewModel: PasswordSaveViewModel

    init(savePasswordUseCase: SavePasswordUseCaseProtocol) {
        _viewModel = StateObject(wrappedValue: PasswordSaveViewModel(savePasswordUseCase: savePasswordUseCase))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Save Password")
                    .font(.title2)
                    .fontWeight(.semibold)

                TextField("URL or name", text: $viewModel.urlOrName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    .autocapitalization(.none)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                TextField("Note (optional)", text: $viewModel.note)
                    .textFieldStyle(.roundedBorder)

                if let err = viewModel.saveError {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Button(action: { viewModel.save() }) {
                    HStack {
                        if viewModel.isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(viewModel.saveMessage ?? (viewModel.isSaving ? "Saving…" : "Save"))
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                }
                .disabled(!viewModel.canSave || viewModel.isSaving)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Save")
    }
}
