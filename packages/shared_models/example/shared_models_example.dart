import 'package:shared_models/shared_models.dart';

void main() {
  final payload = WatchPayload(
    sessionId: 'session-1',
    workoutId: 'day-1',
    workoutName: 'Day 1 - Chest + Triceps',
    blocks: const <WatchExerciseBlock>[
      WatchExerciseBlock(
        blockId: 'day-1-bench-press',
        exerciseId: 'bench-press',
        exerciseName: 'Bench press',
        workingWeightKg: 80.0,
        targetSets: 2,
        repMin: 4,
        repMax: 6,
        restSeconds: 120,
      ),
    ],
  );

  assert(payload.toJson()['schemaVersion'] == 1);
}
