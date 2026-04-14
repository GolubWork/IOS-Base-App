import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var sessions: [TimerSession] = []

    private let timerSessionStore: TimerSessionStoreProtocol

    init(timerSessionStore: TimerSessionStoreProtocol) {
        self.timerSessionStore = timerSessionStore
        timerSessionStore.addObserver { [weak self] sessions in
            self?.sessions = sessions
        }
    }
}
