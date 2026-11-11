import GameCore
import SwiftUI

/// Container for an active run. It picks the screen for the current phase, so later
/// phases (team selection, minigame, reward) are added here without new routes.
struct RunView: View {
    @Environment(RunSession.self) private var session
    @State private var isConfirmingAbandon = false

    var body: some View {
        Group {
            if let run = session.run {
                phaseView(for: run)
                    .id(run.id)
            } else {
                Color.clear
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            if session.run?.phase == .battle {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abandon", role: .destructive) {
                        isConfirmingAbandon = true
                    }
                }
            }
        }
        .confirmationDialog("Abandon this run?", isPresented: $isConfirmingAbandon, titleVisibility: .visible) {
            Button("Abandon Run", role: .destructive) {
                session.endRun()
            }
        } message: {
            Text("Progress in this run will be lost.")
        }
    }

    @ViewBuilder
    private func phaseView(for run: RunState) -> some View {
        switch run.phase {
        case .battle:
            BattlePlaceholderView { outcome in
                session.send(.resolveBattle(outcome))
            }
        case .gameOver(let outcome):
            GameOverView(
                outcome: outcome,
                onPlayAgain: { session.startRun() },
                onMainMenu: { session.endRun() }
            )
        }
    }
}

#Preview("Battle") {
    NavigationStack {
        RunView()
    }
    .environment(RunSession(run: RunEngine.newRun()))
}
