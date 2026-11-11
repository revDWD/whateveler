import Foundation
import Testing
@testable import GameCore

@Suite("RunEngine")
struct RunEngineTests {
    @Test("A new run starts in battle")
    func newRunStartsInBattle() {
        let run = RunEngine.newRun()
        #expect(run.phase == .battle)
        #expect(run.outcome == nil)
    }

    @Test("Resolving the battle ends the run with that outcome", arguments: [RunOutcome.victory, .defeat])
    func resolvingBattleEndsRun(outcome: RunOutcome) throws {
        let run = RunEngine.newRun()
        let finished = try RunEngine.apply(.resolveBattle(outcome), to: run)

        #expect(finished.phase == .gameOver(outcome))
        #expect(finished.outcome == outcome)
        #expect(finished.id == run.id)
    }

    @Test("A finished run rejects further battle results")
    func finishedRunRejectsActions() throws {
        let finished = try RunEngine.apply(.resolveBattle(.victory), to: RunEngine.newRun())

        #expect(throws: RunError.actionNotAllowed(.resolveBattle(.defeat), in: .gameOver(.victory))) {
            try RunEngine.apply(.resolveBattle(.defeat), to: finished)
        }
    }
}
