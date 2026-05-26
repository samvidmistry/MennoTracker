import 'package:program/program.dart';
import 'package:progression/progression.dart';
import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('ProgressionEngine', () {
    const engine = ProgressionEngine();

    test('increment threshold boundary for 6-10 range', () {
      final noBump = engine.computeNextSuggestion(
        state: _state(80),
        lastEntry: _entry(reps: [11], weightKg: 80),
        block: _block(repMin: 6, repMax: 10),
        exercise: _barbellExercise(),
      );

      expect(noBump.reason, SuggestionReason.hold);
      expect(noBump.weightKg, 80);

      final bump = engine.computeNextSuggestion(
        state: _state(80),
        lastEntry: _entry(reps: [12], weightKg: 80),
        block: _block(repMin: 6, repMax: 10),
        exercise: _barbellExercise(),
      );

      expect(bump.reason, SuggestionReason.increase);
      expect(bump.weightKg, 82.5);
    });

    test('deload trigger when a later set drops below repMin', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(80),
        lastEntry: _entry(reps: [10, 5], weightKg: 80),
        block: _block(repMin: 6, repMax: 10),
        exercise: _barbellExercise(),
      );

      expect(suggestion.reason, SuggestionReason.deload);
      expect(suggestion.weightKg, 70.0);
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

    test('mixed-set behaviour still increases when later sets are fine', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(80),
        lastEntry: _entry(reps: [12, 8], weightKg: 80),
        block: _block(repMin: 6, repMax: 10),
        exercise: _barbellExercise(),
      );

      expect(suggestion.reason, SuggestionReason.increase);
      expect(suggestion.weightKg, 82.5);
    });

    test('mixed-set later failure deloads instead of increasing', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(80),
        lastEntry: _entry(reps: [12, 8, 5], weightKg: 80),
        block: _block(repMin: 6, repMax: 10),
        exercise: _barbellExercise(),
      );

      expect(suggestion.reason, SuggestionReason.deload);
      expect(suggestion.weightKg, 70.0);
    });

    test('resume after skipped session holds current state weight', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(80),
        lastEntry: null,
        block: _block(repMin: 6, repMax: 10),
        exercise: _barbellExercise(),
      );

      expect(suggestion.reason, SuggestionReason.hold);
      expect(suggestion.weightKg, 80);
    });

    test('firstTime returns placeholder defaults', () {
      final barbell = engine.computeNextSuggestion(
        state: null,
        lastEntry: null,
        block: _block(repMin: 6, repMax: 10),
        exercise: _barbellExercise(),
      );

      expect(barbell.reason, SuggestionReason.firstTime);
      expect(barbell.weightKg, 20.0);

      final nonBarbell = engine.computeNextSuggestion(
        state: null,
        lastEntry: null,
        block: _block(repMin: 6, repMax: 10),
        exercise: _machineExercise(),
      );

      expect(nonBarbell.reason, SuggestionReason.firstTime);
      expect(nonBarbell.weightKg, 1.0);
    });

    test('hold when top set is in range below bump threshold', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(80),
        lastEntry: _entry(reps: [8], weightKg: 80),
        block: _block(repMin: 6, repMax: 10),
        exercise: _barbellExercise(),
      );

      expect(suggestion.reason, SuggestionReason.hold);
      expect(suggestion.weightKg, 80);
    });

    test('shouldDeloadRemainingSets follows non-first hard-set rule', () {
      expect(
        engine.shouldDeloadRemainingSets(
          _entry(reps: [5], weightKg: 80),
          _block(repMin: 6, repMax: 10),
        ),
        isFalse,
      );
      expect(
        engine.shouldDeloadRemainingSets(
          _entry(reps: [10, 8], weightKg: 80),
          _block(repMin: 6, repMax: 10),
        ),
        isFalse,
      );
      expect(
        engine.shouldDeloadRemainingSets(
          _entry(reps: [10, 5], weightKg: 80),
          _block(repMin: 6, repMax: 10),
        ),
        isTrue,
      );
      expect(
        engine.shouldDeloadRemainingSets(
          _entry(reps: [5, 8], weightKg: 80),
          _block(repMin: 6, repMax: 10),
        ),
        isFalse,
      );
      expect(
        engine.shouldDeloadRemainingSets(
          _entry(reps: [10, 8], failedIndexes: {1}, weightKg: 80),
          _block(repMin: 6, repMax: 10),
        ),
        isTrue,
      );
      expect(
        engine.shouldDeloadRemainingSets(
          _entry(reps: [10, 5], warmupIndexes: {1}, weightKg: 80),
          _block(repMin: 6, repMax: 10),
        ),
        isFalse,
      );
    });

    test('warmup tolerance ignores warmup sets when finding top set', () {
      final suggestion = engine.computeNextSuggestion(
        state: _state(80),
        lastEntry: _entry(reps: [15, 12], warmupIndexes: {0}, weightKg: 80),
        block: _block(repMin: 6, repMax: 10),
        exercise: _barbellExercise(),
      );

      expect(suggestion.reason, SuggestionReason.increase);
      expect(suggestion.weightKg, 82.5);
    });
  });
}

Exercise _barbellExercise() => const Exercise(
      id: 'bench-press',
      name: 'Bench Press',
      category: ExerciseCategory.push,
      defaultIncrementKg: 2.5,
      smallestPlatePairKg: 2.5,
      isBarbell: true,
    );

Exercise _machineExercise() => const Exercise(
      id: 'leg-curl',
      name: 'Leg Curl',
      category: ExerciseCategory.legs,
      defaultIncrementKg: 1,
      smallestPlatePairKg: 1,
      isBarbell: false,
    );

ExerciseBlock _block({required int repMin, required int repMax}) =>
    ExerciseBlock(
      id: 'block-1',
      exerciseId: 'bench-press',
      minSets: 2,
      maxSets: 3,
      repMin: repMin,
      repMax: repMax,
      restMinSeconds: 120,
      restMaxSeconds: 180,
    );

ExerciseState _state(double weightKg) => ExerciseState(
      exerciseId: 'bench-press',
      currentWorkingWeightKg: weightKg,
      lastUpdatedAt: DateTime.utc(2024),
    );

ExerciseEntry _entry({
  required List<int> reps,
  required double weightKg,
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
            targetRepMin: 6,
            targetRepMax: 10,
            actualReps: reps[i],
            completedAt: DateTime.utc(2024, 1, 1, 12, i),
            isWarmup: warmupIndexes.contains(i),
            isFailed: failedIndexes.contains(i),
          ),
      ],
    );
