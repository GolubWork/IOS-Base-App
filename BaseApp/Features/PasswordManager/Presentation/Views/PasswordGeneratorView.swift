import SwiftUI

/// Screen for generating a random password with options (character sets, length) and copying to clipboard.
struct PasswordGeneratorView: View {
    @StateObject private var viewModel: PasswordGeneratorViewModel

    init(generatePasswordUseCase: GeneratePasswordUseCaseProtocol) {
        _viewModel = StateObject(wrappedValue: PasswordGeneratorViewModel(generatePasswordUseCase: generatePasswordUseCase))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Password Generator")
                    .font(.title2)
                    .fontWeight(.semibold)

                Toggle("Uppercase", isOn: $viewModel.useUppercase)
                Toggle("LowerCase", isOn: $viewModel.useLowercase)
                Toggle("Numbers", isOn: $viewModel.useNumbers)
                Toggle("Symbols", isOn: $viewModel.useSymbols)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Length: \(viewModel.lengthInt)")
                        .font(.subheadline)
                    Slider(value: $viewModel.length, in: 4...32, step: 1)
                }

                if !viewModel.generatedPassword.isEmpty {
                    Text(viewModel.generatedPassword)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }

                Button(action: { viewModel.generateAndCopy() }) {
                    HStack {
                        Text("Generate")
                        if viewModel.copiedMessage != nil {
                            Text("• \(viewModel.copiedMessage!)")
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .disabled(!viewModel.canGenerate)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Generator")
    }
}
