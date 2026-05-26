import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:program/program.dart';
import 'package:shared_models/shared_models.dart' as shared;

import '../providers/providers.dart';
import '../widgets/exercise_card.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  late Future<_TodayData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TodayData> _load() async {
    final states = await ref.read(exerciseStateRepoProvider).all();
    final sessions = await ref.read(sessionRepoProvider).listAll();
    return _TodayData(states: states, sessions: sessions);
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(programProvider);
    return FutureBuilder<_TodayData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Could not load today: ${snapshot.error}'));
        }

        final data = snapshot.data ?? const _TodayData();
        final workout = _nextWorkout(program, data.sessions);
        final suggestions = _suggestedWeights(program, workout, data);
        final now = DateTime.now();

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 112),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today: ${DateFormat.EEEE().format(now)}, ${DateFormat.MMMd().format(now)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workout.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        if (data.sessions.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "No sessions yet — let's start with Workout A!",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final block in workout.blocks)
                    ExerciseCard(
                      block: block,
                      exercise: program.exerciseById(block.exerciseId),
                      suggestedWeightKg: suggestions[block.id] ?? 20,
                      setsTarget: block.maxSets,
                      repMin: block.repMin,
                      repMax: block.repMax,
                    ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: SizedBox(
                  height: 60,
                  child: FilledButton.icon(
                    key: const Key('start-workout'),
                    onPressed: () =>
                        _startWorkout(program, workout, suggestions),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Workout'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Workout _nextWorkout(Program program, List<shared.WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return program.workouts.firstWhere(
        (workout) => workout.id == 'workout-a',
        orElse: () => program.workouts.first,
      );
    }

    final lastWorkoutId = sessions.first.workoutId;
    final nextId = lastWorkoutId == 'workout-a' ? 'workout-b' : 'workout-a';
    return program.workouts.firstWhere(
      (workout) => workout.id == nextId,
      orElse: () => program.workouts.first,
    );
  }

  Map<String, double> _suggestedWeights(
    Program program,
    Workout workout,
    _TodayData data,
  ) {
    final engine = ref.read(progressionEngineProvider);
    final statesByExercise = {
      for (final state in data.states) state.exerciseId: state,
    };

    return {
      for (final block in workout.blocks)
        block.id: engine
            .computeNextSuggestion(
              state: statesByExercise[block.exerciseId],
              lastEntry: data.lastEntryFor(block.exerciseId),
              block: block,
              exercise: program.exerciseById(block.exerciseId),
            )
            .weightKg,
    };
  }

  Future<void> _startWorkout(
    Program program,
    Workout workout,
    Map<String, double> suggestions,
  ) async {
    final now = DateTime.now().toUtc();
    final session = shared.WorkoutSession(
      id: now.microsecondsSinceEpoch.toString(),
      programId: program.id,
      workoutId: workout.id,
      dateUtc: DateTime.utc(now.year, now.month, now.day),
      startedAt: now,
    );

    final payload = shared.WatchPayload(
      sessionId: session.id,
      workoutId: workout.id,
      workoutName: workout.name,
      blocks: [
        for (final block in workout.blocks)
          shared.WatchExerciseBlock(
            blockId: block.id,
            exerciseId: block.exerciseId,
            exerciseName: program.exerciseById(block.exerciseId).name,
            workingWeightKg: suggestions[block.id] ?? 20,
            targetSets: block.maxSets,
            repMin: block.repMin,
            repMax: block.repMax,
            restSeconds: block.restMinSeconds,
          ),
      ],
    );

    ref.read(activeWorkoutProvider.notifier).start(
          session: session,
          workout: workout,
          suggestedWeightsKg: suggestions,
        );
    unawaited(ref.read(watchBridgeProvider).sendWorkoutPayload(payload));
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed('/workout');
  }
}

class _TodayData {
  const _TodayData({
    this.states = const [],
    this.sessions = const [],
  });

  final List<shared.ExerciseState> states;
  final List<shared.WorkoutSession> sessions;

  shared.ExerciseEntry? lastEntryFor(String exerciseId) {
    for (final session in sessions) {
      for (final entry in session.entries) {
        if (entry.exerciseId == exerciseId) {
          return entry;
        }
      }
    }
    return null;
  }
}

extension _ProgramLookup on Program {
  Exercise exerciseById(String id) {
    return exercises.firstWhere(
      (exercise) => exercise.id == id,
      orElse: () => exercises.first,
    );
  }
}
