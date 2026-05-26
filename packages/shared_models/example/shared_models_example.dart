import 'package:shared_models/shared_models.dart';

void main() {
  final payload = WatchPayload(
    sessionId: 'session-1',
    workoutId: 'workout-a',
    workoutName: 'Workout A',
    blocks: const <WatchExerciseBlock>[
      WatchExerciseBlock(
        blockId: 'block-1',
        exerciseId: 'bench-press',
        exerciseName: 'Bench press',
        workingWeightKg: 80.0,
        targetSets: 3,
        repMin: 6,
        repMax: 10,
        restSeconds: 150,
      ),
    ],
  );

  assert(payload.toJson()['schemaVersion'] == 1);
}
