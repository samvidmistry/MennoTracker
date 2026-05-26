import SwiftUI

struct RootView: View {
    @StateObject private var coordinator = WorkoutCoordinator()
    @StateObject private var connectivity = ConnectivityManager.shared

    var body: some View {
        Group {
            switch coordinator.phase {
            case .idle:
                IdleView(coordinator: coordinator)
            case .exercising:
                WorkoutView(coordinator: coordinator)
            case .resting(let seconds):
                RestTimerView(seconds: seconds, coordinator: coordinator)
            case .summary:
                SummaryView(
                    coordinator: coordinator,
                    workoutSessionManager: coordinator.workoutSessionManager
                )
            }
        }
        .onAppear {
            ConnectivityManager.shared.activate()
            if let payload = connectivity.currentPayload {
                coordinator.receivePayload(payload)
            }
        }
        .onReceive(connectivity.$currentPayload) { payload in
            guard let payload else { return }
            coordinator.receivePayload(payload)
        }
    }
}
