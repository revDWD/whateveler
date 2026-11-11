import GameCore
import SwiftUI

/// Stand-in for the battle screen. Combat simulation arrives in Milestone 2; until
/// then the tester picks the outcome so the rest of the flow can be exercised.
struct BattlePlaceholderView: View {
    let onResolve: (RunOutcome) -> Void

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                TeamPlaceholder(title: "Your Team", systemImage: "person.3.fill", tint: .blue)
                Text("VS")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
                TeamPlaceholder(title: "Enemy", systemImage: "flame.fill", tint: .red)
            }

            Text("Combat is not implemented yet. Choose a result to continue.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onResolve(.victory)
                } label: {
                    Label("Simulate Victory", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    onResolve(.defeat)
                } label: {
                    Label("Simulate Defeat", systemImage: "xmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .controlSize(.large)
        }
        .padding(24)
        .navigationTitle("Battle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TeamPlaceholder: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(tint.opacity(0.12), in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        BattlePlaceholderView { _ in }
    }
}
