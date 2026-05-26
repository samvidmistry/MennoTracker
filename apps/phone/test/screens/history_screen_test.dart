import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/db/database.dart';
import 'package:menno_tracker/src/providers/providers.dart';
import 'package:menno_tracker/src/screens/history_screen.dart';
import 'package:shared_models/shared_models.dart' as shared;

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('renders session tiles', (tester) async {
    await database.workoutSessionDao.insert(_session('a', 'workout-a', 1));
    await database.workoutSessionDao.insert(_session('b', 'workout-b', 2));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: Scaffold(body: HistoryScreen())),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Workout A'), findsOneWidget);
    expect(find.textContaining('Workout B'), findsOneWidget);
  });
}

shared.WorkoutSession _session(String id, String workoutId, int day) {
  return shared.WorkoutSession(
    id: id,
    programId: 'reduced-v1',
    workoutId: workoutId,
    dateUtc: DateTime.utc(2025, 1, day),
    startedAt: DateTime.utc(2025, 1, day, 8),
    completedAt: DateTime.utc(2025, 1, day, 9),
    entries: [
      shared.ExerciseEntry(
        blockId: workoutId == 'workout-a'
            ? 'workout-a-barbell-bench-press'
            : 'workout-b-high-bar-squat',
        exerciseId: workoutId == 'workout-a'
            ? 'barbell-bench-press'
            : 'high-bar-squat',
        workingWeightKg: 20,
        sets: [
          shared.SetLog(
            targetRepMin: 1,
            targetRepMax: 1,
            actualReps: day,
            completedAt: DateTime.utc(2025, 1, day, 8, 30),
          ),
        ],
      ),
    ],
  );
}
