import Foundation

@MainActor
final class InMemoryTimerSessionStore: ObservableObject, TimerSessionStoreProtocol {
    private var sessions: [TimerSession] = []
    private var observers: [UUID: TimerSessionsObserver] = [:]

    func currentSessions() -> [TimerSession] {
        sessions.sorted(by: { $0.startedAt > $1.startedAt })
    }

    @discardableResult
    func startSession(durationMinutes: Int, startedAt: Date) -> UUID {
        let sessionID = UUID()
        let session = TimerSession(
            id: sessionID,
            durationMinutes: durationMinutes,
            startedAt: startedAt,
            outcome: .running
        )
        sessions.append(session)
        notifyObservers()
        return sessionID
    }

    func finishSession(id: UUID, completedAt: Date) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].outcome = .finished(completedAt: completedAt)
        notifyObservers()
    }

    func resetSession(id: UUID, completedAt: Date) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].outcome = .reset(completedAt: completedAt)
        notifyObservers()
    }

    @discardableResult
    func addObserver(_ observer: @escaping TimerSessionsObserver) -> UUID {
        let observerID = UUID()
        observers[observerID] = observer
        observer(currentSessions())
        return observerID
    }

    func removeObserver(_ observerID: UUID) {
        observers.removeValue(forKey: observerID)
    }

    private func notifyObservers() {
        let orderedSessions = currentSessions()
        for observer in observers.values {
            observer(orderedSessions)
        }
    }
}
