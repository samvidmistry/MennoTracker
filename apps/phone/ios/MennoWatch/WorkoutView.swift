import SwiftUI
import WatchKit

struct WorkoutView: View {
    @ObservedObject var coordinator: WorkoutCoordinator
    @State private var reps = 0
    @State private var crownValue = 0.0
    @State private var didCompleteSet = false

    var body: some View {
        Group {
            if let block = coordinator.currentBlock {
                VStack(spacing: 6) {
                    Text(block.exerciseName)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text("\(block.workingWeightKg, specifier: "%.1f") kg")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Set \(coordinator.currentSetIndex + 1) of \(block.targetSets) \u{2022} \(block.repMin)–\(block.repMax) reps")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Text("\(reps)")
                        .font(.system(size: 80, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)

                    Button("Done Set") {
                        completeSet(isFailed: false)
                    }
                    .buttonStyle(.borderedProminent)
                    .highPriorityGesture(
                        LongPressGesture(minimumDuration: 0.7)
                            .onEnded { _ in
                                completeSet(isFailed: true)
                            }
                    )
                }
                .padding(.horizontal)
                .focusable(true)
                .digitalCrownRotation(
                    $crownValue,
                    from: 0,
                    through: 50,
                    by: 1,
                    sensitivity: .medium
                )
                .onAppear {
                    resetReps()
                }
                .onChange(of: coordinator.currentBlockIndex) { _, _ in
                    resetReps()
                }
                .onChange(of: coordinator.currentSetIndex) { _, _ in
                    resetReps()
                }
                .onChange(of: crownValue) { _, newValue in
                    let clamped = min(max(newValue, 0), 50)
                    if clamped != newValue {
                        crownValue = clamped
                    }
                    reps = Int(clamped.rounded())
                }
            } else {
                Text("No exercise loaded")
                    .onAppear {
                        coordinator.finish()
                    }
            }
        }
    }

    private func resetReps() {
        guard let block = coordinator.currentBlock else { return }
        didCompleteSet = false
        reps = min(max(block.repMax, 0), 50)
        crownValue = Double(reps)
    }

    private func completeSet(isFailed: Bool) {
        guard !didCompleteSet, let block = coordinator.currentBlock else { return }
        didCompleteSet = true
        WKInterfaceDevice.current().play(.notification)
        coordinator.recordSet(reps: reps, isFailed: isFailed)
        coordinator.startRest(seconds: block.restSeconds)
    }
}
