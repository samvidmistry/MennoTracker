import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/db/database.dart';
import 'package:menno_tracker/src/providers/providers.dart';
import 'package:menno_tracker/src/screens/today_screen.dart';
import 'package:shared_models/shared_models.dart' as shared;

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('empty history starts with Day 1', (tester) async {
    await _pumpToday(tester, database);

    expect(find.text('Day 1 - Chest + Triceps'), findsOneWidget);
    expect(
      find.text("No sessions yet - let's start with Day 1 - Chest + Triceps."),
      findsOneWidget,
    );
  });

  testWidgets('after Day 1, next workout is Day 2', (tester) async {
    await database.workoutSessionDao.insert(
      shared.WorkoutSession(
        id: 'session-day-1',
        programId: 'bro-split-v1',
        workoutId: 'day-1',
        dateUtc: DateTime.utc(2025, 1, 1),
        startedAt: DateTime.utc(2025, 1, 1, 8),
      ),
    );

    await _pumpToday(tester, database);

    expect(find.text('Day 2 - Back + Biceps'), findsOneWidget);
  });

  testWidgets('after Day 5, next workout cycles to Day 1', (tester) async {
    await database.workoutSessionDao.insert(
      shared.WorkoutSession(
        id: 'session-day-5',
        programId: 'bro-split-v1',
        workoutId: 'day-5',
        dateUtc: DateTime.utc(2025, 1, 5),
        startedAt: DateTime.utc(2025, 1, 5, 8),
      ),
    );

    await _pumpToday(tester, database);

    expect(find.text('Day 1 - Chest + Triceps'), findsOneWidget);
  });

  testWidgets('swiping reveals the next future workout', (tester) async {
    await _pumpToday(tester, database);

    expect(find.textContaining('Today:'), findsOneWidget);
    expect(find.text('Day 1 - Chest + Triceps'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Day 2 - Back + Biceps'), findsOneWidget);
    expect(find.textContaining('Today:'), findsNothing);
  });

  testWidgets('Start Workout button only shows on the today page',
      (tester) async {
    await _pumpToday(tester, database);

    expect(find.byKey(const Key('start-workout')), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('start-workout')), findsNothing);
  });

  testWidgets('Day 1 bench suggestion increases after two top sets',
      (tester) async {
    await database.workoutSessionDao.insert(
      _sessionWithBench(
        id: 'bench-top',
        day: 1,
        reps: [6, 6],
        weightKg: 60,
      ),
    );
    await database.workoutSessionDao.insert(_session('latest-day-5', 'day-5', 5));

    await _pumpToday(tester, database);

    expect(find.text('Day 1 - Chest + Triceps'), findsOneWidget);
    expect(find.text('62.5 kg'), findsOneWidget);
  });

  testWidgets('Day 1 bench suggestion deloads after two minimum misses',
      (tester) async {
    await database.workoutSessionDao.insert(
      _sessionWithBench(
        id: 'bench-first-miss',
        day: 1,
        reps: [4, 3],
        weightKg: 90,
      ),
    );
    await database.workoutSessionDao.insert(
      _sessionWithBench(
        id: 'bench-second-miss',
        day: 8,
        reps: [3, 3],
        weightKg: 90,
      ),
    );
    await database.workoutSessionDao.insert(_session('latest-day-5', 'day-5', 10));

    await _pumpToday(tester, database);

    expect(find.text('Day 1 - Chest + Triceps'), findsOneWidget);
    expect(find.text('80 kg'), findsOneWidget);
  });
}

Future<void> _pumpToday(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: Scaffold(body: TodayScreen())),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
}

shared.WorkoutSession _session(String id, String workoutId, int day) {
  return shared.WorkoutSession(
    id: id,
    programId: 'bro-split-v1',
    workoutId: workoutId,
    dateUtc: DateTime.utc(2025, 1, day),
    startedAt: DateTime.utc(2025, 1, day, 8),
  );
}

shared.WorkoutSession _sessionWithBench({
  required String id,
  required int day,
  required List<int> reps,
  required double weightKg,
}) {
  return shared.WorkoutSession(
    id: id,
    programId: 'bro-split-v1',
    workoutId: 'day-1',
    dateUtc: DateTime.utc(2025, 1, day),
    startedAt: DateTime.utc(2025, 1, day, 8),
    completedAt: DateTime.utc(2025, 1, day, 9),
    entries: [
      shared.ExerciseEntry(
        blockId: 'day-1-bench-press',
        exerciseId: 'bench-press',
        workingWeightKg: weightKg,
        sets: [
          for (var index = 0; index < reps.length; index += 1)
            shared.SetLog(
              targetRepMin: 4,
              targetRepMax: 6,
              actualReps: reps[index],
              completedAt: DateTime.utc(2025, 1, day, 8, 15 + index),
            ),
        ],
      ),
    ],
  );
}
