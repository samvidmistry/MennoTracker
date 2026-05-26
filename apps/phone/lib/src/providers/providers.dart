import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:program/program.dart';
import 'package:progression/progression.dart';

import '../bridge/watch_bridge.dart';
import '../db/database.dart';

final _database = AppDatabase();

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

final programProvider = Provider<Program>((ref) => kReducedProgram);

final progressionConfigProvider = StateProvider<ProgressionConfig>(
  (ref) => const ProgressionConfig(),
);

final progressionEngineProvider = Provider<ProgressionEngine>((ref) {
  final config = ref.watch(progressionConfigProvider);
  return ProgressionEngine(config: config);
});

final watchBridgeProvider = Provider<WatchBridge>((ref) => WatchBridge());
