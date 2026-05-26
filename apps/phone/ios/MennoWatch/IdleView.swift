import SwiftUI

struct IdleView: View {
    @ObservedObject var coordinator: WorkoutCoordinator

    var body: some View {
        VStack(spacing: 12) {
            if let payload = coordinator.currentPayload {
                Text(payload.workoutName)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Button("Start \(payload.workoutName)") {
                    coordinator.advance()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("Open MennoTracker on iPhone")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
