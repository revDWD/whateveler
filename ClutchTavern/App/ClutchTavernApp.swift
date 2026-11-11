import SwiftUI

@main
struct ClutchTavernApp: App {
    @State private var session = RunSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
    }
}
