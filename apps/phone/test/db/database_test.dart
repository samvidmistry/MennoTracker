import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/db/database.dart';
import 'package:shared_models/shared_models.dart' as shared;

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('WorkoutSessionDao inserts and lists newest first', () async {
    final older = shared.WorkoutSession(
      id: 'older-session',
      programId: 'reduced-v1',
      workoutId: 'workout-a',
      dateUtc: DateTime.utc(2025, 1, 1),
      startedAt: DateTime.utc(2025, 1, 1, 8),
      completedAt: DateTime.utc(2025, 1, 1, 9),
      entries: [
        shared.ExerciseEntry(
          blockId: 'block-a',
          exerciseId: 'barbell-bench-press',
          workingWeightKg: 80,
          sets: [
            shared.SetLog(
              targetRepMin: 6,
              targetRepMax: 10,
              actualReps: 8,
              completedAt: DateTime.utc(2025, 1, 1, 8, 30),
            ),
          ],
        ),
      ],
    );
    final newer = shared.WorkoutSession(
      id: 'newer-session',
      programId: 'reduced-v1',
      workoutId: 'workout-b',
      dateUtc: DateTime.utc(2025, 1, 2),
      startedAt: DateTime.utc(2025, 1, 2, 8),
    );

    await database.workoutSessionDao.insert(older);
    await database.workoutSessionDao.insert(newer);

    final sessions = await database.workoutSessionDao.listAll();

    expect(sessions.map((session) => session.id), [newer.id, older.id]);
    expect(await database.workoutSessionDao.byId(older.id), older);
  });

  test('ExerciseStateDao upserts and preserves weight history', () async {
    final state = shared.ExerciseState(
      exerciseId: 'high-bar-squat',
      currentWorkingWeightKg: 100,
      lastUpdatedAt: DateTime.utc(2025, 1, 3),
      history: [
        shared.WeightChange(
          fromKg: 95,
          toKg: 100,
          atUtc: DateTime.utc(2025, 1, 3),
          reason: shared.WeightChangeReason.increment,
        ),
      ],
    );

    await database.exerciseStateDao.upsert(state);
    final loaded = await database.exerciseStateDao.get(state.exerciseId);

    expect(loaded, state);
    expect(loaded?.history, state.history);
  });

  test('SettingsDao stores string, double, and int values', () async {
    await database.settingsDao.setString('unit', 'kg');
    await database.settingsDao.setDouble('trainingMax', 87.5);
    await database.settingsDao.setInt('restSeconds', 120);

    expect(await database.settingsDao.getString('unit'), 'kg');
    expect(await database.settingsDao.getDouble('trainingMax'), 87.5);
    expect(await database.settingsDao.getInt('restSeconds'), 120);
  });
}
