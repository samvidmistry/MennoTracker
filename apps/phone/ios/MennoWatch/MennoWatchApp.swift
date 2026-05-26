import SwiftUI

@main
struct MennoWatchApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        ConnectivityManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    ConnectivityManager.shared.activate()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        ConnectivityManager.shared.activate()
                    }
                }
        }
    }
}
