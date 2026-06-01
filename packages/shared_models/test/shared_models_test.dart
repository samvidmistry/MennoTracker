import 'package:shared_models/shared_models.dart';
import 'package:test/test.dart';

void main() {
  group('JSON roundtrips preserve equality', () {
    test('WeightChange', () {
      final value = sampleWeightChange();

      expect(WeightChange.fromJson(value.toJson()), value);
    });

    test('ExerciseState', () {
      final value = sampleExerciseState();

      expect(ExerciseState.fromJson(value.toJson()), value);
    });

    test('SetLog', () {
      final value = sampleSetLog();

      expect(SetLog.fromJson(value.toJson()), value);
    });

    test('ExerciseEntry', () {
      final value = sampleExerciseEntry();

      expect(ExerciseEntry.fromJson(value.toJson()), value);
    });

    test('WorkoutSession', () {
      final value = sampleWorkoutSession();

      expect(WorkoutSession.fromJson(value.toJson()), value);
    });

    test('WatchExerciseBlock', () {
      final value = sampleWatchExerciseBlock();

      expect(WatchExerciseBlock.fromJson(value.toJson()), value);
    });

    test('WatchPayload', () {
      final value = sampleWatchPayload();

      expect(WatchPayload.fromJson(value.toJson()), value);
    });
  });

  group('copyWith', () {
    test('WeightChange changes one field', () {
      final original = sampleWeightChange();
      final changed = original.copyWith(toKg: 95.0);

      expect(changed.toKg, 95.0);
      expect(changed.fromKg, original.fromKg);
      expect(changed.atUtc, original.atUtc);
      expect(changed.reason, original.reason);
    });

    test('ExerciseState changes one field', () {
      final original = sampleExerciseState();
      final changed = original.copyWith(currentWorkingWeightKg: 90.0);

      expect(changed.currentWorkingWeightKg, 90.0);
      expect(changed.exerciseId, original.exerciseId);
      expect(changed.lastUpdatedAt, original.lastUpdatedAt);
      expect(changed.history, original.history);
    });

    test('SetLog changes one field', () {
      final original = sampleSetLog();
      final changed = original.copyWith(rpe: 8.5);

      expect(changed.rpe, 8.5);
      expect(changed.targetRepMin, original.targetRepMin);
      expect(changed.targetRepMax, original.targetRepMax);
      expect(changed.actualReps, original.actualReps);
      expect(changed.completedAt, original.completedAt);
      expect(changed.isWarmup, original.isWarmup);
      expect(changed.isFailed, original.isFailed);
    });

    test('ExerciseEntry changes one field', () {
      final original = sampleExerciseEntry();
      final changed = original.copyWith(workingWeightKg: 95.0);

      expect(changed.workingWeightKg, 95.0);
      expect(changed.blockId, original.blockId);
      expect(changed.exerciseId, original.exerciseId);
      expect(changed.sets, original.sets);
      expect(changed.suggestionAppliedKg, original.suggestionAppliedKg);
    });

    test('WorkoutSession changes one field', () {
      final original = sampleWorkoutSession();
      final completedAt = DateTime.utc(2025, 1, 1, 13);
      final changed = original.copyWith(completedAt: completedAt);

      expect(changed.completedAt, completedAt);
      expect(changed.id, original.id);
      expect(changed.programId, original.programId);
      expect(changed.workoutId, original.workoutId);
      expect(changed.dateUtc, original.dateUtc);
      expect(changed.startedAt, original.startedAt);
      expect(changed.entries, original.entries);
      expect(changed.schemaVersion, original.schemaVersion);
    });

    test('WatchPayload changes one field', () {
      final original = sampleWatchPayload();
      final changed = original.copyWith(workoutName: 'Day 2 - Back + Biceps');

      expect(changed.workoutName, 'Day 2 - Back + Biceps');
      expect(changed.schemaVersion, original.schemaVersion);
      expect(changed.sessionId, original.sessionId);
      expect(changed.workoutId, original.workoutId);
      expect(changed.blocks, original.blocks);
    });

    test('WatchExerciseBlock changes one field', () {
      final original = sampleWatchExerciseBlock();
      final changed = original.copyWith(restSeconds: 180);

      expect(changed.restSeconds, 180);
      expect(changed.blockId, original.blockId);
      expect(changed.exerciseId, original.exerciseId);
      expect(changed.exerciseName, original.exerciseName);
      expect(changed.workingWeightKg, original.workingWeightKg);
      expect(changed.targetSets, original.targetSets);
      expect(changed.repMin, original.repMin);
      expect(changed.repMax, original.repMax);
    });
  });

  test('DateTime fields serialize and parse back as UTC', () {
    final local = DateTime(2025, 1, 2, 3, 4, 5, 6);

    final weightChange = WeightChange(
      fromKg: 80.0,
      toKg: 82.5,
      atUtc: local,
      reason: WeightChangeReason.increment,
    );
    expect(WeightChange.fromJson(weightChange.toJson()).atUtc.isUtc, isTrue);

    final exerciseState = ExerciseState(
      exerciseId: 'bench-press',
      currentWorkingWeightKg: 82.5,
      lastUpdatedAt: local,
      history: <WeightChange>[weightChange],
    );
    expect(
      ExerciseState.fromJson(exerciseState.toJson()).lastUpdatedAt.isUtc,
      isTrue,
    );

    final setLog = SetLog(
      targetRepMin: 6,
      targetRepMax: 10,
      actualReps: 9,
      completedAt: local,
    );
    expect(SetLog.fromJson(setLog.toJson()).completedAt.isUtc, isTrue);

    final session = WorkoutSession(
      id: 'session-1',
      programId: 'program-1',
      workoutId: 'day-1',
      dateUtc: local,
      startedAt: local.add(const Duration(minutes: 5)),
      completedAt: local.add(const Duration(hours: 1)),
      entries: <ExerciseEntry>[
        ExerciseEntry(
          blockId: 'block-1',
          exerciseId: 'bench-press',
          workingWeightKg: 82.5,
          sets: <SetLog>[setLog],
        ),
      ],
    );
    final parsedSession = WorkoutSession.fromJson(session.toJson());
    expect(parsedSession.dateUtc.isUtc, isTrue);
    expect(parsedSession.startedAt.isUtc, isTrue);
    expect(parsedSession.completedAt?.isUtc, isTrue);
  });

  test('SetLog defaults warmup and failed flags to false when missing', () {
    final json = sampleSetLog().toJson()
      ..remove('isWarmup')
      ..remove('isFailed');

    final parsed = SetLog.fromJson(json);

    expect(parsed.isWarmup, isFalse);
    expect(parsed.isFailed, isFalse);
  });

  test('WeightChangeReason.fromJson falls back to manual for unknown values',
      () {
    expect(
        WeightChangeReason.fromJson('unexpected'), WeightChangeReason.manual);
    expect(parseWeightChangeReason(null), WeightChangeReason.manual);

    final parsed = WeightChange.fromJson(<String, Object?>{
      'fromKg': 80,
      'toKg': 82.5,
      'atUtc': DateTime.utc(2025, 1, 1).toIso8601String(),
      'reason': 'unknown',
    });

    expect(parsed.reason, WeightChangeReason.manual);
  });

  test('WorkoutSession schemaVersion defaults to 1 when missing', () {
    final json = sampleWorkoutSession().toJson()..remove('schemaVersion');

    expect(WorkoutSession.fromJson(json).schemaVersion, 1);
  });

  test('WatchPayload schemaVersion defaults to 1 when missing', () {
    final json = sampleWatchPayload().toJson()..remove('schemaVersion');

    expect(WatchPayload.fromJson(json).schemaVersion, 1);
  });

  test('WorkoutSession list equality covers 3 entries with 4 sets each', () {
    final session = WorkoutSession(
      id: 'session-list-test',
      programId: 'program-1',
      workoutId: 'day-1',
      dateUtc: DateTime.utc(2025, 1, 1),
      startedAt: DateTime.utc(2025, 1, 1, 12),
      entries: List<ExerciseEntry>.generate(
        3,
        (entryIndex) => sampleExerciseEntry(index: entryIndex).copyWith(
          sets: List<SetLog>.generate(
            4,
            (setIndex) => sampleSetLog(index: entryIndex * 4 + setIndex),
          ),
        ),
      ),
    );

    final parsed = WorkoutSession.fromJson(session.toJson());

    expect(parsed, session);
    expect(parsed.entries, hasLength(3));
    for (final entry in parsed.entries) {
      expect(entry.sets, hasLength(4));
    }
  });
}

WeightChange sampleWeightChange({int index = 0}) => WeightChange(
      fromKg: 80.0 + index,
      toKg: 82.5 + index,
      atUtc: DateTime.utc(2025, 1, 1, 12, index),
      reason: WeightChangeReason.increment,
    );

ExerciseState sampleExerciseState({int index = 0}) => ExerciseState(
      exerciseId: 'bench-press-$index',
      currentWorkingWeightKg: 82.5 + index,
      lastUpdatedAt: DateTime.utc(2025, 1, 1, 12, index),
      history: <WeightChange>[
        sampleWeightChange(index: index),
        sampleWeightChange(index: index + 1).copyWith(
          reason: WeightChangeReason.manual,
        ),
      ],
    );

SetLog sampleSetLog({int index = 0}) => SetLog(
      targetRepMin: 6,
      targetRepMax: 10,
      actualReps: 8 + (index % 3),
      rpe: 7.5 + (index % 2) * 0.5,
      completedAt: DateTime.utc(2025, 1, 1, 12, index),
      isWarmup: index.isEven,
      isFailed: index % 5 == 0,
    );

ExerciseEntry sampleExerciseEntry({int index = 0}) => ExerciseEntry(
      blockId: 'block-$index',
      exerciseId: 'bench-press-$index',
      workingWeightKg: 82.5 + index,
      sets: <SetLog>[
        sampleSetLog(index: index),
        sampleSetLog(index: index + 1),
      ],
      suggestionAppliedKg: 82.5 + index,
    );

WorkoutSession sampleWorkoutSession() => WorkoutSession(
      id: 'session-1',
      programId: 'program-1',
      workoutId: 'day-1',
      dateUtc: DateTime.utc(2025, 1, 1),
      startedAt: DateTime.utc(2025, 1, 1, 12),
      completedAt: DateTime.utc(2025, 1, 1, 13),
      entries: <ExerciseEntry>[
        sampleExerciseEntry(),
        sampleExerciseEntry(index: 1),
      ],
    );

WatchExerciseBlock sampleWatchExerciseBlock({int index = 0}) =>
    WatchExerciseBlock(
      blockId: 'block-$index',
      exerciseId: 'bench-press-$index',
      exerciseName: 'Bench press $index',
      workingWeightKg: 82.5 + index,
      targetSets: 3,
      repMin: 6,
      repMax: 10,
      restSeconds: 150,
    );

WatchPayload sampleWatchPayload() => WatchPayload(
      sessionId: 'session-1',
      workoutId: 'day-1',
      workoutName: 'Day 1 - Chest + Triceps',
      blocks: <WatchExerciseBlock>[
        sampleWatchExerciseBlock(),
        sampleWatchExerciseBlock(index: 1),
      ],
    );
