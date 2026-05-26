import 'package:program/program.dart';
import 'package:test/test.dart';

void main() {
  group('kReducedProgram', () {
    test('contains Workout A and Workout B', () {
      expect(kReducedProgram.workouts, hasLength(2));
      expect(kReducedProgram.workouts.map((workout) => workout.id), [
        'workout-a',
        'workout-b',
      ]);
    });

    test('has the expected block counts', () {
      final workoutA = kReducedProgram.workouts.singleWhere(
        (workout) => workout.id == 'workout-a',
      );
      final workoutB = kReducedProgram.workouts.singleWhere(
        (workout) => workout.id == 'workout-b',
      );

      expect(workoutA.blocks, hasLength(6));
      expect(workoutB.blocks, hasLength(7));
    });

    test('all blocks reference valid exercise ids', () {
      final exerciseIds =
          kReducedProgram.exercises.map((exercise) => exercise.id).toSet();

      for (final workout in kReducedProgram.workouts) {
        for (final block in workout.blocks) {
          expect(exerciseIds, contains(block.exerciseId));
        }
      }
    });

    test('all exercise increments are positive', () {
      for (final exercise in kReducedProgram.exercises) {
        expect(exercise.smallestPlatePairKg, greaterThan(0));
        expect(exercise.defaultIncrementKg, greaterThan(0));
      }
    });

    test('all rep and rest ranges are ordered', () {
      for (final workout in kReducedProgram.workouts) {
        for (final block in workout.blocks) {
          expect(block.repMin, lessThanOrEqualTo(block.repMax));
          expect(block.restMinSeconds, lessThanOrEqualTo(block.restMaxSeconds));
        }
      }
    });

    test('uses the reduced schedule pattern', () {
      expect(kReducedProgram.schedulePattern, ['A', 'B', 'A', 'B']);
    });

    test('JSON roundtrip preserves equality', () {
      final roundTripped = Program.fromJson(kReducedProgram.toJson());

      expect(roundTripped, kReducedProgram);
      expect(roundTripped.hashCode, kReducedProgram.hashCode);
      expect(roundTripped.toJson(), equals(kReducedProgram.toJson()));
    });
  });
}
