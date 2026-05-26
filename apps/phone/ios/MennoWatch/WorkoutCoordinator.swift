import Combine
import Foundation

final class WorkoutCoordinator: ObservableObject {
    enum Phase: Equatable {
        case idle
        case exercising
        case resting(seconds: Int)
        case summary
    }

    @Published var phase: Phase = .idle
    @Published var currentPayload: WatchPayload?
    @Published var currentBlockIndex = 0
    @Published var currentSetIndex = 0
    @Published var completedSets: [SetLog] = []
    @Published private(set) var startedAt: Date?
    @Published private(set) var completedAt: Date?

    let workoutSessionManager = WorkoutSessionManager()

    var currentBlock: WatchExerciseBlock? {
        guard let blocks = currentPayload?.blocks,
              blocks.indices.contains(currentBlockIndex) else {
            return nil
        }
        return blocks[currentBlockIndex]
    }

    var elapsedTime: TimeInterval {
        guard let startedAt else { return 0 }
        return (completedAt ?? Date()).timeIntervalSince(startedAt)
    }

    func receivePayload(_ payload: WatchPayload) {
        guard currentPayload != payload else { return }
        currentPayload = payload
        ConnectivityManager.shared.currentPayload = payload
        currentBlockIndex = 0
        currentSetIndex = 0
        completedSets = []
        startedAt = nil
        completedAt = nil
        phase = .idle
    }

    func recordSet(reps: Int) {
        recordSet(reps: reps, isFailed: false)
    }

    func recordSet(reps: Int, isFailed: Bool) {
        guard let block = currentBlock else { return }

        let setLog = SetLog(
            targetRepMin: block.repMin,
            targetRepMax: block.repMax,
            actualReps: max(0, reps),
            rpe: nil,
            completedAt: Date(),
            isWarmup: false,
            isFailed: isFailed
        )

        completedSets.append(setLog)
        ConnectivityManager.shared.sendSetCompleted(
            setLog,
            sessionId: currentPayload?.sessionId,
            workoutId: currentPayload?.workoutId,
            block: block,
            blockIndex: currentBlockIndex,
            setIndex: currentSetIndex
        )
    }

    func advance() {
        switch phase {
        case .idle:
            guard let payload = currentPayload, !payload.blocks.isEmpty else {
                finish()
                return
            }
            startedAt = startedAt ?? Date()
            completedAt = nil
            workoutSessionManager.start(payload: payload)
            phase = .exercising
        case .exercising, .resting:
            advanceAfterCompletedSet()
        case .summary:
            break
        }
    }

    func startRest(seconds: Int) {
        guard seconds > 0 else {
            advance()
            return
        }
        phase = .resting(seconds: seconds)
    }

    func skipRest() {
        guard case .resting = phase else { return }
        advance()
    }

    func finish() {
        if startedAt == nil {
            startedAt = Date()
        }
        if completedAt == nil {
            completedAt = Date()
        }
        phase = .summary
        workoutSessionManager.finish(
            payload: currentPayload,
            completedSets: completedSets
        )
    }

    private func advanceAfterCompletedSet() {
        guard let payload = currentPayload, let block = currentBlock else {
            finish()
            return
        }

        if currentSetIndex + 1 < block.targetSets {
            currentSetIndex += 1
            phase = .exercising
            return
        }

        if currentBlockIndex + 1 < payload.blocks.count {
            currentBlockIndex += 1
            currentSetIndex = 0
            phase = .exercising
            return
        }

        finish()
    }
}
