import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:program/program.dart';
import 'package:progression/progression.dart';
import 'package:shared_models/shared_models.dart' as shared;

import '../bridge/watch_bridge.dart';
import '../db/database.dart';
import '../services/notification_service.dart';

final _database = AppDatabase();
final _notificationService = NotificationService();

final databaseProvider = Provider<AppDatabase>((ref) => _database);

final exerciseStateRepoProvider = Provider<ExerciseStateDao>(
  (ref) => ref.watch(databaseProvider).exerciseStateDao,
);

final sessionRepoProvider = Provider<WorkoutSessionDao>(
  (ref) => ref.watch(databaseProvider).workoutSessionDao,
);

final settingsRepoProvider = Provider<SettingsDao>(
  (ref) => ref.watch(databaseProvider).settingsDao,
);

final programProvider = Provider<Program>((ref) => kBroSplitProgram);

final progressionConfigProvider = StateProvider<ProgressionConfig>(
  (ref) => const ProgressionConfig(),
);

final progressionEngineProvider = Provider<ProgressionEngine>((ref) {
  final config = ref.watch(progressionConfigProvider);
  return ProgressionEngine(config: config);
});

final watchBridgeProvider = Provider<WatchBridge>((ref) => WatchBridge());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => _notificationService);

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutController, ActiveWorkout?>(
  (ref) => ActiveWorkoutController(),
);

class ActiveWorkout {
  ActiveWorkout({
    required this.session,
    required this.workout,
    required Map<String, double> suggestedWeightsKg,
    required List<shared.ExerciseEntry> entries,
  })  : suggestedWeightsKg = Map<String, double>.unmodifiable(
          suggestedWeightsKg,
        ),
        entries = List<shared.ExerciseEntry>.unmodifiable(entries);

  final shared.WorkoutSession session;
  final Workout workout;
  final Map<String, double> suggestedWeightsKg;
  final List<shared.ExerciseEntry> entries;

  ActiveWorkout copyWith({
    shared.WorkoutSession? session,
    Workout? workout,
    Map<String, double>? suggestedWeightsKg,
    List<shared.ExerciseEntry>? entries,
  }) {
    return ActiveWorkout(
      session: session ?? this.session,
      workout: workout ?? this.workout,
      suggestedWeightsKg: suggestedWeightsKg ?? this.suggestedWeightsKg,
      entries: entries ?? this.entries,
    );
  }
}

class ActiveWorkoutController extends StateNotifier<ActiveWorkout?> {
  ActiveWorkoutController() : super(null);

  void start({
    required shared.WorkoutSession session,
    required Workout workout,
    required Map<String, double> suggestedWeightsKg,
  }) {
    final entries = _initialEntries(workout, suggestedWeightsKg);
    state = ActiveWorkout(
      session: session.copyWith(entries: entries),
      workout: workout,
      suggestedWeightsKg: suggestedWeightsKg,
      entries: entries,
    );
  }

  void updateEntries(List<shared.ExerciseEntry> entries) {
    final active = state;
    if (active == null) {
      return;
    }

    state = active.copyWith(
      session: active.session.copyWith(entries: entries),
      entries: entries,
    );
  }

  void clear() {
    state = null;
  }

  List<shared.ExerciseEntry> _initialEntries(
    Workout workout,
    Map<String, double> suggestedWeightsKg,
  ) {
    return [
      for (final block in workout.blocks)
        shared.ExerciseEntry(
          blockId: block.id,
          exerciseId: block.exerciseId,
          workingWeightKg: suggestedWeightsKg[block.id] ?? 20,
          suggestionAppliedKg: suggestedWeightsKg[block.id],
        ),
    ];
  }
}
