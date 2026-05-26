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

  testWidgets('empty history starts with Workout A', (tester) async {
    await _pumpToday(tester, database);

    expect(find.text('Workout A'), findsOneWidget);
    expect(find.text("No sessions yet — let's start with Workout A!"), findsOneWidget);
  });

  testWidgets('after Workout A, next workout is Workout B', (tester) async {
    await database.workoutSessionDao.insert(
      shared.WorkoutSession(
        id: 'session-a',
        programId: 'reduced-v1',
        workoutId: 'workout-a',
        dateUtc: DateTime.utc(2025, 1, 1),
        startedAt: DateTime.utc(2025, 1, 1, 8),
      ),
    );

    await _pumpToday(tester, database);

    expect(find.text('Workout B'), findsOneWidget);
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
