import SwiftUI

enum AppRoute: Hashable {
    case run
}

/// The navigation path is derived from `RunSession` rather than stored separately,
/// so the screen shown can never disagree with whether a run is active.
struct RootView: View {
    @Environment(RunSession.self) private var session

    var body: some View {
        @Bindable var session = session

        NavigationStack(path: $session.routes) {
            MainMenuView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .run:
                        RunView()
                    }
                }
        }
    }
}

extension RunSession {
    var routes: [AppRoute] {
        get { run == nil ? [] : [.run] }
        set {
            if newValue.isEmpty { endRun() }
        }
    }
}

#Preview {
    RootView()
        .environment(RunSession())
}
