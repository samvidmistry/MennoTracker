import Foundation
import SwiftUI

struct SummaryView: View {
    @ObservedObject var coordinator: WorkoutCoordinator
    @ObservedObject var workoutSessionManager: WorkoutSessionManager
    @State private var didSend = false

    var body: some View {
        VStack(spacing: 10) {
            Text("Workout Complete")
                .font(.headline)
                .multilineTextAlignment(.center)

            VStack(spacing: 4) {
                Text(formatElapsed(coordinator.elapsedTime))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("\(coordinator.completedSets.count) sets done")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if workoutSessionManager.isAvailable {
                healthMetrics
            } else {
                Text("HealthKit unavailable")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.orange.opacity(0.18), in: Capsule())
                    .overlay(
                        Capsule().stroke(.orange.opacity(0.45), lineWidth: 1)
                    )
            }

            Button(didSend ? "Sent" : "Send to iPhone") {
                ConnectivityManager.shared.sendSessionComplete()
                didSend = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
    }

    private var healthMetrics: some View {
        VStack(spacing: 3) {
            Text("Avg HR: \(heartRateText(workoutSessionManager.averageHeartRate))")
            Text("Max HR: \(heartRateText(workoutSessionManager.maxHeartRate))")
            Text("Calories: \(calorieText(workoutSessionManager.activeEnergyKilocalories))")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .monospacedDigit()
    }

    private func heartRateText(_ value: Double?) -> String {
        guard let value else { return "--" }
        return "\(Int(value.rounded())) bpm"
    }

    private func calorieText(_ value: Double?) -> String {
        guard let value else { return "--" }
        return "\(Int(value.rounded())) kcal"
    }

    private func formatElapsed(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval.rounded()))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
