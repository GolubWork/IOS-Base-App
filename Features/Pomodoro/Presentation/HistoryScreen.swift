import SwiftUI

struct HistoryScreen: View {
    @StateObject private var viewModel: HistoryViewModel

    init(viewModel: HistoryViewModel) {
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
                        List(viewModel.sessions) { session in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Started: \(session.startedAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.headline)
                                    .foregroundStyle(GameThemePalette.chickenWhite)
                                Text("Duration: \(session.durationMinutes) min")
                                    .font(.subheadline)
                                    .foregroundStyle(GameThemePalette.chickenGoldenYellow)
                                Text(outcomeText(for: session.outcome))
                                    .font(.footnote)
                                    .foregroundStyle(GameThemePalette.chickenWhite.opacity(0.85))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(GameThemePalette.chickenSkyTop.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(GameThemePalette.chickenWhite.opacity(0.3), lineWidth: 1)
                            }
                            .listRowInsets(EdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .frame(maxWidth: min(w * 0.92, 560))
                        Spacer(minLength: 0)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .navigationTitle("History")
    }

    private func outcomeText(for outcome: TimerSessionOutcome) -> String {
        switch outcome {
        case .running:
            return "Outcome: running"
        case .finished(let completedAt):
            return "Outcome: finished at \(completedAt.formatted(date: .omitted, time: .shortened))"
        case .reset(let completedAt):
            return "Outcome: reset at \(completedAt.formatted(date: .omitted, time: .shortened))"
        }
    }
}
