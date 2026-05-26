// JSON contract MUST match packages/shared_models/lib/src/models.dart. camelCase keys, ISO-8601 UTC for Date, enums as .name strings.
import Foundation

struct WatchPayload: Codable, Equatable {
    let schemaVersion: Int
    let sessionId: String
    let workoutId: String
    let workoutName: String
    let blocks: [WatchExerciseBlock]
}

struct WatchExerciseBlock: Codable, Equatable, Identifiable {
    var id: String { blockId }
    let blockId: String
    let exerciseId: String
    let exerciseName: String
    let workingWeightKg: Double
    let targetSets: Int
    let repMin: Int
    let repMax: Int
    let restSeconds: Int
}

struct SetLog: Codable, Equatable {
    let targetRepMin: Int
    let targetRepMax: Int
    let actualReps: Int
    let rpe: Double?
    let completedAt: Date
    let isWarmup: Bool
    let isFailed: Bool
}
