import GameCore
import SwiftUI

struct GameOverView: View {
    let outcome: RunOutcome
    let onPlayAgain: () -> Void
    let onMainMenu: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: outcome == .victory ? "trophy.fill" : "xmark.shield.fill")
                .font(.system(size: 72))
                .foregroundStyle(outcome == .victory ? .yellow : .red)
                .accessibilityHidden(true)

            Text(outcome == .victory ? "Victory" : "Defeat")
                .font(.largeTitle.bold())

            Text("Game Over")
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    Label("Play Again", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: onMainMenu) {
                    Label("Main Menu", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .controlSize(.large)
        }
        .padding(24)
        .navigationTitle("Game Over")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Victory") {
    NavigationStack {
        GameOverView(outcome: .victory, onPlayAgain: {}, onMainMenu: {})
    }
}

#Preview("Defeat") {
    NavigationStack {
        GameOverView(outcome: .defeat, onPlayAgain: {}, onMainMenu: {})
    }
}
