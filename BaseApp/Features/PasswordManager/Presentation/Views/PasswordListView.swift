import SwiftUI

/// Screen showing saved passwords; tap a card to copy its password to the clipboard.
struct PasswordListView: View {
    @StateObject private var viewModel: PasswordListViewModel

    init(getPasswordsUseCase: GetPasswordsUseCaseProtocol) {
        _viewModel = StateObject(wrappedValue: PasswordListViewModel(getPasswordsUseCase: getPasswordsUseCase))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let err = viewModel.loadError {
                Text(err)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.passwords.isEmpty {
                Text("No saved passwords")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.passwords) { item in
                            PasswordCard(
                                password: item,
                                isCopied: viewModel.copiedId == item.id,
                                onTap: { viewModel.copyPassword(item) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Passwords")
        .onAppear { viewModel.load() }
        .refreshable { viewModel.load() }
    }
}

/// Single password entry card (url/name, note, tap to copy).
private struct PasswordCard: View {
    let password: Password
    let isCopied: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(password.urlOrName)
                    .font(.headline)
                    .foregroundColor(.primary)
                if !password.note.isEmpty {
                    Text(password.note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                if isCopied {
                    Text("Copied")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
