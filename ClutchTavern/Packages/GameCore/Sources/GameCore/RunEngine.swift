import Foundation

public enum RunAction: Sendable, Equatable {
    /// Placeholder until the combat simulation exists: the caller supplies the result.
    case resolveBattle(RunOutcome)
}

public enum RunError: Error, Equatable {
    case actionNotAllowed(RunAction, in: RunPhase)
}

/// Pure transition rules for a run. Holds no state and performs no I/O, so the same
/// rules can later back an offline session, bots, or an online authority.
public enum RunEngine {
    public static func newRun(id: UUID = UUID()) -> RunState {
        RunState(id: id, phase: .battle)
    }

    public static func apply(_ action: RunAction, to state: RunState) throws(RunError) -> RunState {
        var next = state
        switch (state.phase, action) {
        case (.battle, .resolveBattle(let outcome)):
            next.phase = .gameOver(outcome)
        case (.gameOver, _):
            throw .actionNotAllowed(action, in: state.phase)
        }
        return next
    }
}
