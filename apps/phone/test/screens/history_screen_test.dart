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
    await database.workoutSessionDao.insert(_session('a', 'day-1', 1));
    await database.workoutSessionDao.insert(_session('b', 'day-2', 2));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: Scaffold(body: HistoryScreen())),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Day 1 - Chest + Triceps'), findsOneWidget);
    expect(find.textContaining('Day 2 - Back + Biceps'), findsOneWidget);
  });
}

shared.WorkoutSession _session(String id, String workoutId, int day) {
  return shared.WorkoutSession(
    id: id,
    programId: 'bro-split-v1',
    workoutId: workoutId,
    dateUtc: DateTime.utc(2025, 1, day),
    startedAt: DateTime.utc(2025, 1, day, 8),
    completedAt: DateTime.utc(2025, 1, day, 9),
    entries: [
      shared.ExerciseEntry(
        blockId: workoutId == 'day-1' ? 'day-1-bench-press' : 'day-2-row',
        exerciseId: workoutId == 'day-1' ? 'bench-press' : 'row',
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
