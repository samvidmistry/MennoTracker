import 'package:program/program.dart';
import 'package:test/test.dart';

void main() {
  group('kBroSplitProgram', () {
    test('contains the five-day split in order', () {
      expect(kBroSplitProgram.workouts, hasLength(5));
      expect(kBroSplitProgram.workouts.map((workout) => workout.id), [
        'day-1',
        'day-2',
        'day-3',
        'day-4',
        'day-5',
      ]);
    });

    test('matches the prescribed workout block counts', () {
      expect(
          kBroSplitProgram.workouts.map((workout) => workout.blocks.length), [
        4,
        5,
        4,
        5,
        6,
      ]);
    });

    test('matches the prescribed exercises, sets, reps, and rests', () {
      _expectWorkout(
        'day-1',
        [
          _ExpectedBlock('bench-press', 2, 4, 6, 120, 180),
          _ExpectedBlock('incline-machine-press', 2, 8, 12, 90, 90),
          _ExpectedBlock('pec-deck-cable-fly', 2, 12, 15, 60, 90),
          _ExpectedBlock('triceps-pressdown', 2, 10, 15, 60, 90),
        ],
      );
      _expectWorkout(
        'day-2',
        [
          _ExpectedBlock('row', 2, 6, 8, 120, 120),
          _ExpectedBlock('neutral-grip-lat-pulldown', 3, 8, 12, 90, 90),
          _ExpectedBlock('cable-row', 2, 10, 15, 90, 90),
          _ExpectedBlock('reverse-pec-deck', 2, 12, 15, 60, 60),
          _ExpectedBlock('cable-curl', 2, 10, 15, 60, 90),
        ],
      );
      _expectWorkout(
        'day-3',
        [
          _ExpectedBlock('squat', 2, 4, 6, 120, 180),
          _ExpectedBlock('leg-press-hack-squat', 2, 8, 12, 90, 120),
          _ExpectedBlock('leg-curl', 3, 10, 15, 60, 90),
          _ExpectedBlock('calf-raise', 2, 8, 15, 60, 90),
        ],
      );
      _expectWorkout(
        'day-4',
        [
          _ExpectedBlock('overhead-press', 2, 4, 6, 120, 180),
          _ExpectedBlock('cable-lateral-raise', 3, 12, 15, 60, 90),
          _ExpectedBlock('reverse-pec-deck', 2, 12, 15, 60, 60),
          _ExpectedBlock('incline-machine-press-push-up', 2, 10, 15, 90, 90),
          _ExpectedBlock('pulldown-cable-row', 2, 10, 15, 90, 90),
        ],
      );
      _expectWorkout(
        'day-5',
        [
          _ExpectedBlock('romanian-deadlift', 2, 6, 8, 120, 180),
          _ExpectedBlock('triceps-pressdown', 3, 10, 15, 60, 90),
          _ExpectedBlock('overhead-triceps-extension', 2, 10, 15, 60, 90),
          _ExpectedBlock('preacher-curl', 3, 8, 12, 60, 90),
          _ExpectedBlock('incline-curl-cable-curl', 2, 10, 15, 60, 90),
          _ExpectedBlock('optional-abs', 2, 10, 15, 60, 60),
        ],
      );
    });

    test('all blocks reference valid exercise ids', () {
      final exerciseIds =
          kBroSplitProgram.exercises.map((exercise) => exercise.id).toSet();

      for (final workout in kBroSplitProgram.workouts) {
        for (final block in workout.blocks) {
          expect(exerciseIds, contains(block.exerciseId));
        }
      }
    });

    test('all exercise increments are positive', () {
      for (final exercise in kBroSplitProgram.exercises) {
        expect(exercise.smallestPlatePairKg, greaterThan(0));
        expect(exercise.defaultIncrementKg, greaterThan(0));
      }
    });

    test('compounds use two hard sets and fixed increments', () {
      const expectedIncrements = {
        'bench-press': 2.5,
        'squat': 2.5,
        'overhead-press': 1.25,
        'row': 2.5,
        'romanian-deadlift': 2.5,
      };

      for (final entry in expectedIncrements.entries) {
        final exercise = kBroSplitProgram.exercises.singleWhere(
          (exercise) => exercise.id == entry.key,
        );
        final block = kBroSplitProgram.workouts
            .expand((workout) => workout.blocks)
            .singleWhere((block) => block.exerciseId == entry.key);

        expect(block.minSets, 2);
        expect(block.maxSets, 2);
        expect(exercise.defaultIncrementKg, entry.value);
      }
    });

    test('all rep and rest ranges are ordered', () {
      for (final workout in kBroSplitProgram.workouts) {
        for (final block in workout.blocks) {
          expect(block.repMin, lessThanOrEqualTo(block.repMax));
          expect(block.restMinSeconds, lessThanOrEqualTo(block.restMaxSeconds));
        }
      }
    });

    test('uses the five-day schedule pattern', () {
      expect(kBroSplitProgram.schedulePattern, [
        'day-1',
        'day-2',
        'day-3',
        'day-4',
        'day-5',
      ]);
    });

    test('JSON roundtrip preserves equality', () {
      final roundTripped = Program.fromJson(kBroSplitProgram.toJson());

      expect(roundTripped, kBroSplitProgram);
      expect(roundTripped.hashCode, kBroSplitProgram.hashCode);
      expect(roundTripped.toJson(), equals(kBroSplitProgram.toJson()));
    });
  });
}

void _expectWorkout(String workoutId, List<_ExpectedBlock> expected) {
  final workout = kBroSplitProgram.workouts.singleWhere(
    (workout) => workout.id == workoutId,
  );

  expect(workout.blocks, hasLength(expected.length));
  for (var index = 0; index < expected.length; index += 1) {
    final block = workout.blocks[index];
    final expectedBlock = expected[index];
    expect(block.exerciseId, expectedBlock.exerciseId);
    expect(block.minSets, expectedBlock.sets);
    expect(block.maxSets, expectedBlock.sets);
    expect(block.repMin, expectedBlock.repMin);
    expect(block.repMax, expectedBlock.repMax);
    expect(block.restMinSeconds, expectedBlock.restMinSeconds);
    expect(block.restMaxSeconds, expectedBlock.restMaxSeconds);
  }
}

class _ExpectedBlock {
  const _ExpectedBlock(
    this.exerciseId,
    this.sets,
    this.repMin,
    this.repMax,
    this.restMinSeconds,
    this.restMaxSeconds,
  );

  final String exerciseId;
  final int sets;
  final int repMin;
  final int repMax;
  final int restMinSeconds;
  final int restMaxSeconds;
}
