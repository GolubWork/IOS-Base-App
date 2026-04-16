import SwiftUI

struct TimerScreen: View {
    @StateObject private var viewModel: TimerViewModel

    init(viewModel: TimerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                GameThemePalette.skyBackgroundGradient
                    .frame(width: w, height: h)
                    .clipped()

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)
                        VStack(spacing: 18) {
                            VStack(spacing: 14) {
                                HStack(spacing: 10) {
                                    ForEach(TimerViewModel.TimerPreset.allCases) { preset in
                                        Button {
                                            viewModel.selectedPreset = preset
                                        } label: {
                                            Text(preset.title)
                                                .font(.headline)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                        }
                                        .buttonStyle(
                                            ChickenChipButtonStyle(
                                                isSelected: viewModel.selectedPreset == preset
                                            )
                                        )
                                    }
                                }

                                if viewModel.selectedPreset == .custom {
                                    TextField("Minutes", text: $viewModel.customMinutesText)
                                        .keyboardType(.numberPad)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(GameThemePalette.chickenWhite.opacity(0.94))
                                        .foregroundStyle(GameThemePalette.chickenSkyTop)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(GameThemePalette.chickenSkyBlue.opacity(0.8), lineWidth: 1)
                                        }
                                }
                            }
                            .padding(16)
                            .background(GameThemePalette.chickenWhite.opacity(0.22))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(GameThemePalette.chickenWhite.opacity(0.45), lineWidth: 1)
                            }

                            Text(viewModel.remainingTimeText)
                                .font(.system(size: 48, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(GameThemePalette.chickenWhite)
                                .frame(maxWidth: .infinity)

                            HStack(spacing: 12) {
                                Button("Start") {
                                    viewModel.start()
                                }
                                .buttonStyle(ChickenActionButtonStyle(prominent: true))
                                .disabled(viewModel.isRunning)

                                Button("Reset") {
                                    viewModel.reset()
                                }
                                .buttonStyle(ChickenActionButtonStyle(prominent: false))
                                .disabled(!viewModel.isRunning)
                            }
                        }
                        .padding(20)
                        .background(GameThemePalette.chickenSkyTop.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(GameThemePalette.chickenWhite.opacity(0.4), lineWidth: 1)
                        }
                        .frame(maxWidth: min(w * 0.9, 460))
                        Spacer(minLength: 0)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: w, height: h)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .navigationTitle("Timer")
    }
}

private struct ChickenChipButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isSelected ? GameThemePalette.chickenSkyTop : GameThemePalette.chickenWhite)
            .background(
                Group {
                    if isSelected {
                        GameThemePalette.goldControlGradient
                    } else {
                        GameThemePalette.chickenSkyTop.opacity(configuration.isPressed ? 0.7 : 0.55)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(GameThemePalette.chickenWhite.opacity(0.35), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct ChickenActionButtonStyle: ButtonStyle {
    let prominent: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(prominent ? GameThemePalette.chickenSkyTop : GameThemePalette.chickenWhite)
            .background(
                Group {
                    if prominent {
                        GameThemePalette.goldControlGradient
                    } else {
                        GameThemePalette.fireAccentGradient.opacity(configuration.isPressed ? 0.8 : 1)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(GameThemePalette.chickenWhite.opacity(0.35), lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
