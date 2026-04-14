import Foundation

@MainActor
protocol TimerSessionStoreProtocol: AnyObject {
    typealias TimerSessionsObserver = ([TimerSession]) -> Void

    func currentSessions() -> [TimerSession]
    @discardableResult
    func startSession(durationMinutes: Int, startedAt: Date) -> UUID
    func finishSession(id: UUID, completedAt: Date)
    func resetSession(id: UUID, completedAt: Date)
    @discardableResult
    func addObserver(_ observer: @escaping TimerSessionsObserver) -> UUID
    func removeObserver(_ observerID: UUID)
}
