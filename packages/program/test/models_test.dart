import 'package:program/program.dart';
import 'package:test/test.dart';

void main() {
  group('models', () {
    test('Exercise JSON roundtrip is symmetric', () {
      const exercise = Exercise(
        id: 'barbell-bench-press',
        name: 'Barbell bench press',
        category: ExerciseCategory.push,
        defaultIncrementKg: 2.5,
        smallestPlatePairKg: 2.5,
        isBarbell: true,
      );

      final json = exercise.toJson();
      final roundTripped = Exercise.fromJson(json);

      expect(roundTripped, exercise);
      expect(roundTripped.hashCode, exercise.hashCode);
      expect(roundTripped.toJson(), equals(json));
    });

    test('ExerciseBlock JSON roundtrip is symmetric', () {
      const block = ExerciseBlock(
        id: 'day-1-bench',
        exerciseId: 'barbell-bench-press',
        minSets: 3,
        maxSets: 3,
        repMin: 6,
        repMax: 10,
        restMinSeconds: 150,
        restMaxSeconds: 180,
        equipmentHint: 'barbell',
      );

      final json = block.toJson();
      final roundTripped = ExerciseBlock.fromJson(json);

      expect(roundTripped, block);
      expect(roundTripped.hashCode, block.hashCode);
      expect(roundTripped.toJson(), equals(json));
    });

    test('Workout JSON roundtrip is symmetric', () {
      const workout = Workout(
        id: 'day-1',
        name: 'Day 1',
        blocks: [
          ExerciseBlock(
            id: 'day-1-bench',
            exerciseId: 'barbell-bench-press',
            minSets: 3,
            maxSets: 3,
            repMin: 6,
            repMax: 10,
            restMinSeconds: 150,
            restMaxSeconds: 180,
          ),
        ],
      );

      final json = workout.toJson();
      final roundTripped = Workout.fromJson(json);

      expect(roundTripped, workout);
      expect(roundTripped.hashCode, workout.hashCode);
      expect(roundTripped.toJson(), equals(json));
    });

    test('Program JSON roundtrip is symmetric', () {
      const program = Program(
        id: 'test-program',
        name: 'Test Program',
        weeks: 8,
        schedulePattern: ['A', 'B'],
        workouts: [
          Workout(
            id: 'day-1',
            name: 'Day 1',
            blocks: [
              ExerciseBlock(
                id: 'day-1-bench',
                exerciseId: 'barbell-bench-press',
                minSets: 3,
                maxSets: 3,
                repMin: 6,
                repMax: 10,
                restMinSeconds: 150,
                restMaxSeconds: 180,
              ),
            ],
          ),
        ],
        exercises: [
          Exercise(
            id: 'barbell-bench-press',
            name: 'Barbell bench press',
            category: ExerciseCategory.push,
            defaultIncrementKg: 2.5,
            smallestPlatePairKg: 2.5,
            isBarbell: true,
          ),
        ],
      );

      final json = program.toJson();
      final roundTripped = Program.fromJson(json);

      expect(roundTripped, program);
      expect(roundTripped.hashCode, program.hashCode);
      expect(roundTripped.toJson(), equals(json));
    });

    test('const constructors and value equality work', () {
      const exercise = Exercise(
        id: 'seated-row',
        name: 'Seated row',
        category: ExerciseCategory.pull,
        defaultIncrementKg: 2.5,
        smallestPlatePairKg: 2.5,
        isBarbell: false,
      );
      const matchingExercise = Exercise(
        id: 'seated-row',
        name: 'Seated row',
        category: ExerciseCategory.pull,
        defaultIncrementKg: 2.5,
        smallestPlatePairKg: 2.5,
        isBarbell: false,
      );
      const block = ExerciseBlock(
        id: 'day-2-row',
        exerciseId: 'seated-row',
        minSets: 3,
        maxSets: 3,
        repMin: 8,
        repMax: 12,
        restMinSeconds: 120,
        restMaxSeconds: 180,
      );
      const workout = Workout(
        id: 'day-2',
        name: 'Day 2',
        blocks: [block],
      );
      const matchingWorkout = Workout(
        id: 'day-2',
        name: 'Day 2',
        blocks: [block],
      );
      const program = Program(
        id: 'const-program',
        name: 'Const Program',
        weeks: 8,
        schedulePattern: ['B'],
        workouts: [workout],
        exercises: [exercise],
      );

      expect(exercise, matchingExercise);
      expect(exercise.hashCode, matchingExercise.hashCode);
      expect(workout, matchingWorkout);
      expect(workout.hashCode, matchingWorkout.hashCode);
      expect(program.workouts.single.blocks.single.exerciseId, exercise.id);
    });
  });
}
