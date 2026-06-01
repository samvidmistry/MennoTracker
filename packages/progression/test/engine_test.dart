import 'package:program/program.dart';
import 'package:progression/progression.dart';
import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('ProgressionEngine', () {
    const engine = ProgressionEngine();

    test('increases compounds only after all hard sets hit the top', () {
      final noBump = engine.computeNextSuggestion(
        state: _state(60),
        lastEntry: _entry(reps: [6, 5], repMin: 4, repMax: 6, weightKg: 60),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(noBump.reason, SuggestionReason.hold);
      expect(noBump.weightKg, 60);

      final bump = engine.computeNextSuggestion(
        state: _state(60),
        lastEntry: _entry(reps: [6, 6], repMin: 4, repMax: 6, weightKg: 60),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(bump.reason, SuggestionReason.increase);
      expect(bump.weightKg, 62.5);
    });

    test('increases non-compounds by the smallest exercise jump', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(12),
        lastEntry: _entry(
          reps: [20, 20, 20],
          repMin: 12,
          repMax: 20,
          weightKg: 12,
        ),
        block: _block(repMin: 12, repMax: 20, sets: 3),
        exercise: _machineExercise(incrementKg: 1),
      );

      expect(suggestion.reason, SuggestionReason.increase);
      expect(suggestion.weightKg, 13);
    });

    test('uses the overhead press microload increment', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(40),
        lastEntry: _entry(reps: [6, 6], repMin: 4, repMax: 6, weightKg: 40),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(
          id: 'overhead-press',
          incrementKg: 1.25,
          smallestPlatePairKg: 1.25,
        ),
      );

      expect(suggestion.reason, SuggestionReason.increase);
      expect(suggestion.weightKg, 41.25);
    });

    test('holds when any hard set misses the top of the range', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(12),
        lastEntry: _entry(
          reps: [20, 18, 15],
          repMin: 12,
          repMax: 20,
          weightKg: 12,
        ),
        block: _block(repMin: 12, repMax: 20, sets: 3),
        exercise: _machineExercise(incrementKg: 1),
      );

      expect(suggestion.reason, SuggestionReason.hold);
      expect(suggestion.weightKg, 12);
    });

    test('holds when fewer than the planned hard sets are logged', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(60),
        lastEntry: _entry(reps: [6], repMin: 4, repMax: 6, weightKg: 60),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(suggestion.reason, SuggestionReason.hold);
      expect(suggestion.weightKg, 60);
    });

    test('extra hard sets must also hit the top to increase', () {
      final extraTopSet = engine.computeNextSuggestion(
        state: _state(60),
        lastEntry: _entry(reps: [6, 6, 6], repMin: 4, repMax: 6, weightKg: 60),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(extraTopSet.reason, SuggestionReason.increase);
      expect(extraTopSet.weightKg, 62.5);

      final extraMissedTop = engine.computeNextSuggestion(
        state: _state(60),
        lastEntry: _entry(reps: [6, 6, 5], repMin: 4, repMax: 6, weightKg: 60),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(extraMissedTop.reason, SuggestionReason.hold);
      expect(extraMissedTop.weightKg, 60);
    });

    test('first minimum-rep miss holds the same weight', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(90),
        lastEntry: _entry(reps: [4, 3], repMin: 4, repMax: 6, weightKg: 90),
        previousEntry: _entry(
          reps: [5, 4],
          repMin: 4,
          repMax: 6,
          weightKg: 90,
          daysAgo: 7,
        ),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(suggestion.reason, SuggestionReason.hold);
      expect(suggestion.weightKg, 90);
    });

    test('second consecutive minimum-rep miss deloads by 10 percent', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(90),
        lastEntry: _entry(reps: [3, 3], repMin: 4, repMax: 6, weightKg: 90),
        previousEntry: _entry(
          reps: [4, 3],
          repMin: 4,
          repMax: 6,
          weightKg: 90,
          daysAgo: 7,
        ),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(suggestion.reason, SuggestionReason.deload);
      expect(suggestion.weightKg, 80);
    });

    test('warmups do not count toward top hits or misses', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(60),
        lastEntry: _entry(
          reps: [2, 6, 6],
          repMin: 4,
          repMax: 6,
          weightKg: 60,
          warmupIndexes: {0},
        ),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(suggestion.reason, SuggestionReason.increase);
      expect(suggestion.weightKg, 62.5);
      expect(
        engine.missedMinimumReps(
          _entry(
            reps: [2, 4, 4],
            repMin: 4,
            repMax: 6,
            weightKg: 60,
            warmupIndexes: {0},
          ),
        ),
        isFalse,
      );
    });

    test('already-updated state is not increased or deloaded again', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(
          62.5,
          lastUpdatedAt: DateTime.utc(2024, 1, 1, 13),
        ),
        lastEntry: _entry(reps: [6, 6], repMin: 4, repMax: 6, weightKg: 60),
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(suggestion.reason, SuggestionReason.hold);
      expect(suggestion.weightKg, 62.5);
    });

    test('smallest-plate snapping', () {
      expect(ProgressionEngine.snapToPlateUp(82.0, 2.5), 82.5);
      expect(ProgressionEngine.snapToPlateUp(80.0, 2.5), 80.0);
      expect(ProgressionEngine.snapToPlateUp(80.1, 2.5), 82.5);
      expect(ProgressionEngine.snapToPlateUp(7.3, 1.0), 8.0);

      expect(ProgressionEngine.snapToPlateDown(82.0, 2.5), 80.0);
      expect(ProgressionEngine.snapToPlateDown(80.0, 2.5), 80.0);
      expect(ProgressionEngine.snapToPlateDown(80.1, 2.5), 80.0);
      expect(ProgressionEngine.snapToPlateDown(7.3, 1.0), 7.0);
    });

    test('resume after skipped session holds current state weight', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(80),
        lastEntry: null,
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(suggestion.reason, SuggestionReason.hold);
      expect(suggestion.weightKg, 80);
    });

    test('firstTime returns placeholder defaults', () {
      final barbell = engine.computeNextSuggestion(
        state: null,
        lastEntry: null,
        block: _block(repMin: 4, repMax: 6, sets: 2),
        exercise: _barbellExercise(incrementKg: 2.5),
      );

      expect(barbell.reason, SuggestionReason.firstTime);
      expect(barbell.weightKg, 20.0);

      final nonBarbell = engine.computeNextSuggestion(
        state: null,
        lastEntry: null,
        block: _block(repMin: 10, repMax: 15, sets: 2),
        exercise: _machineExercise(incrementKg: 1),
      );

      expect(nonBarbell.reason, SuggestionReason.firstTime);
      expect(nonBarbell.weightKg, 1.0);
    });
  });
}

Exercise _barbellExercise({
  String id = 'bench-press',
  required double incrementKg,
  double? smallestPlatePairKg,
}) =>
    Exercise(
      id: id,
      name: 'Bench Press',
      category: ExerciseCategory.push,
      defaultIncrementKg: incrementKg,
      smallestPlatePairKg: smallestPlatePairKg ?? incrementKg,
      isBarbell: true,
    );

Exercise _machineExercise({required double incrementKg}) => Exercise(
      id: 'leg-curl',
      name: 'Leg Curl',
      category: ExerciseCategory.legs,
      defaultIncrementKg: incrementKg,
      smallestPlatePairKg: incrementKg,
      isBarbell: false,
    );

ExerciseBlock _block({
  required int repMin,
  required int repMax,
  required int sets,
}) =>
    ExerciseBlock(
      id: 'block-1',
      exerciseId: 'bench-press',
      minSets: sets,
      maxSets: sets,
      repMin: repMin,
      repMax: repMax,
      restMinSeconds: 120,
      restMaxSeconds: 180,
    );

ExerciseState _state(
  double weightKg, {
  DateTime? lastUpdatedAt,
}) =>
    ExerciseState(
      exerciseId: 'bench-press',
      currentWorkingWeightKg: weightKg,
      lastUpdatedAt: lastUpdatedAt ?? DateTime.utc(2023),
    );

ExerciseEntry _entry({
  required List<int> reps,
  required int repMin,
  required int repMax,
  required double weightKg,
  int daysAgo = 0,
  Set<int> warmupIndexes = const {},
  Set<int> failedIndexes = const {},
}) =>
    ExerciseEntry(
      blockId: 'block-1',
      exerciseId: 'bench-press',
      workingWeightKg: weightKg,
      sets: [
        for (var i = 0; i < reps.length; i++)
          SetLog(
            targetRepMin: repMin,
            targetRepMax: repMax,
            actualReps: reps[i],
            completedAt: DateTime.utc(2024, 1, 1 - daysAgo, 12, i),
            isWarmup: warmupIndexes.contains(i),
            isFailed: failedIndexes.contains(i),
          ),
      ],
    );
