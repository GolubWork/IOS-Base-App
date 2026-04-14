import Foundation

enum TimerSessionOutcome: Equatable {
    case running
    case finished(completedAt: Date)
    case reset(completedAt: Date)
}

struct TimerSession: Identifiable, Equatable {
    let id: UUID
    let durationMinutes: Int
    let startedAt: Date
    var outcome: TimerSessionOutcome
}
