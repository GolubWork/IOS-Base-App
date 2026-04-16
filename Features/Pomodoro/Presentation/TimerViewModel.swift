import Foundation

@MainActor
final class TimerViewModel: ObservableObject {
    enum TimerPreset: String, CaseIterable, Identifiable {
        case twenty
        case fifty
        case custom

        var id: String { rawValue }

        var title: String {
            switch self {
            case .twenty:
                return "20 min"
            case .fifty:
                return "50 min"
            case .custom:
                return "Custom"
            }
        }
    }

    @Published var selectedPreset: TimerPreset = .twenty
    @Published var customMinutesText: String = "25"
    @Published private(set) var isRunning = false
    @Published private(set) var remainingSeconds = 0

    private let timerSessionStore: TimerSessionStoreProtocol
    private var activeSessionID: UUID?
    private var countdownTask: Task<Void, Never>?

    init(timerSessionStore: TimerSessionStoreProtocol) {
        self.timerSessionStore = timerSessionStore
    }

    var remainingTimeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start() {
        guard !isRunning else { return }
        let minutes = selectedDurationMinutes()
        guard minutes > 0 else { return }

        let sessionID = timerSessionStore.startSession(durationMinutes: minutes, startedAt: Date())
        activeSessionID = sessionID
        isRunning = true
        remainingSeconds = minutes * 60
        startCountdown(for: sessionID)
    }

    func reset() {
        guard isRunning, let sessionID = activeSessionID else { return }
        countdownTask?.cancel()
        countdownTask = nil
        timerSessionStore.resetSession(id: sessionID, completedAt: Date())
        activeSessionID = nil
        isRunning = false
        remainingSeconds = 0
    }

    private func startCountdown(for sessionID: UUID) {
        countdownTask = Task { @MainActor in
            while remainingSeconds > 0, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                remainingSeconds -= 1
            }

            guard !Task.isCancelled else { return }
            timerSessionStore.finishSession(id: sessionID, completedAt: Date())
            activeSessionID = nil
            isRunning = false
        }
    }

    private func selectedDurationMinutes() -> Int {
        switch selectedPreset {
        case .twenty:
            return 20
        case .fifty:
            return 50
        case .custom:
            return Int(customMinutesText) ?? 0
        }
    }
}
