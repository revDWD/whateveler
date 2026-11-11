import Foundation

public enum RunOutcome: String, Sendable, Codable, Equatable {
    case victory
    case defeat
}

/// Team selection, the minigame, and rewards will be inserted before `battle`
/// in later milestones.
public enum RunPhase: Sendable, Codable, Equatable {
    case battle
    case gameOver(RunOutcome)
}

/// Mutated only by `RunEngine`, so every phase change passes through one set of rules.
public struct RunState: Sendable, Codable, Equatable, Identifiable {
    public let id: UUID
    public internal(set) var phase: RunPhase

    init(id: UUID, phase: RunPhase) {
        self.id = id
        self.phase = phase
    }

    public var outcome: RunOutcome? {
        if case .gameOver(let outcome) = phase { return outcome }
        return nil
    }
}
