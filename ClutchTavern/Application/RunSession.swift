import GameCore
import Observation
import os

/// Owns the active run for the app. Views send intentions here; `RunEngine` decides
/// whether they are legal. A future online session would keep this interface while
/// forwarding actions to a remote authority.
@MainActor
@Observable
final class RunSession {
    private(set) var run: RunState?

    private let logger = Logger(subsystem: "ClutchTavern", category: "RunSession")

    init(run: RunState? = nil) {
        self.run = run
    }

    /// Starting a run while one is active replaces it (used by "Play Again").
    func startRun() {
        run = RunEngine.newRun()
    }

    func send(_ action: RunAction) {
        guard let current = run else {
            logger.error("Ignored \(String(describing: action), privacy: .public): no active run")
            return
        }
        do {
            run = try RunEngine.apply(action, to: current)
        } catch {
            // Rejections such as a repeated tap are expected and leave state unchanged.
            logger.notice("Rejected action: \(String(describing: error), privacy: .public)")
        }
    }

    func endRun() {
        run = nil
    }
}
