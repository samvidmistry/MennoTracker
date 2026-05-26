import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/app.dart';
import 'package:menno_tracker/src/db/database.dart';
import 'package:menno_tracker/src/providers/providers.dart';
import 'package:menno_tracker/src/screens/workout_screen.dart';
import 'package:program/program.dart';
import 'package:shared_models/shared_models.dart' as shared;

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('finishing a tiny workout persists and navigates to history',
      (tester) async {
    final observer = _RecordingNavigatorObserver();
    final session = shared.WorkoutSession(
      id: 'tiny-session',
      programId: _program.id,
      workoutId: _workout.id,
      dateUtc: DateTime.utc(2025, 1, 1),
      startedAt: DateTime.utc(2025, 1, 1, 8),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          programProvider.overrideWithValue(_program),
        ],
        child: MaterialApp(
          navigatorObservers: [observer],
          routes: {
            '/history': (_) => const Scaffold(body: Text('History reached')),
          },
          home: WorkoutScreen(
            session: session,
            workout: _workout,
            suggestedWeightsKg: const {'tiny-block': 20},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('done-set')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('finish-workout')));
    await tester.pumpAndSettle();

    final saved = await database.workoutSessionDao.byId('tiny-session');
    expect(saved, isNotNull);
    expect(saved!.entries.single.sets.single.actualReps, 1);
    expect(find.text('History reached'), findsOneWidget);
    expect(observer.pushedNames, contains('/history'));
  });

  testWidgets('editing working weight updates the workout without exceptions',
      (tester) async {
    final session = shared.WorkoutSession(
      id: 'edit-weight-session',
      programId: _program.id,
      workoutId: _workout.id,
      dateUtc: DateTime.utc(2025, 1, 1),
      startedAt: DateTime.utc(2025, 1, 1, 8),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          programProvider.overrideWithValue(_program),
        ],
        child: MaterialApp(
          routes: {
            '/history': (_) => const Scaffold(body: Text('History reached')),
          },
          home: WorkoutScreen(
            session: session,
            workout: _workout,
            suggestedWeightsKg: const {'tiny-block': 20},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('working-weight')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('weight-field')), '22.5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('22.5 kg'), findsWidgets);

    await tester.tap(find.byKey(const Key('done-set')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('finish-workout')));
    await tester.pumpAndSettle();

    final saved = await database.workoutSessionDao.byId('edit-weight-session');
    expect(saved, isNotNull);
    expect(saved!.entries.single.workingWeightKg, 22.5);
  });

  testWidgets('started workout remains available from the Workout tab',
      (tester) async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MennoTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('start-workout')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(container.read(activeWorkoutProvider), isNotNull);

    expect(find.textContaining('Exercise 1 of'), findsOneWidget);
    expect(find.text('No workout in progress'), findsNothing);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Exercise 1 of'), findsOneWidget);
    expect(find.text('No workout in progress'), findsNothing);
  });
}

const _exercise = Exercise(
  id: 'tiny-squat',
  name: 'Tiny squat',
  category: ExerciseCategory.legs,
  defaultIncrementKg: 2.5,
  smallestPlatePairKg: 2.5,
  isBarbell: true,
);

const _block = ExerciseBlock(
  id: 'tiny-block',
  exerciseId: 'tiny-squat',
  minSets: 1,
  maxSets: 1,
  repMin: 1,
  repMax: 1,
  restMinSeconds: 1,
  restMaxSeconds: 1,
);

const _workout = Workout(
  id: 'tiny-workout',
  name: 'Tiny Workout',
  blocks: [_block],
);

const _program = Program(
  id: 'tiny-program',
  name: 'Tiny Program',
  weeks: 1,
  schedulePattern: ['A'],
  workouts: [_workout],
  exercises: [_exercise],
);

class _RecordingNavigatorObserver extends NavigatorObserver {
  final pushedNames = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedNames.add(route.settings.name);
    super.didPush(route, previousRoute);
  }
}
