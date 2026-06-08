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
  static const int _horizonSessions = 14; // 2 weeks of consecutive days.

  late Future<_TodayData> _future;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        final sessions = _plannedSessions(program, data);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: _PageIndicator(
                count: sessions.length,
                currentIndex: _currentPage,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return RefreshIndicator(
                        onRefresh: () async => _refresh(),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 112),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dateLabel(session),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    session.workout.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  if (session.isToday &&
                                      data.sessions.isEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      "No sessions yet - let's start with ${session.workout.name}.",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final block in session.workout.blocks)
                              ExerciseCard(
                                block: block,
                                exercise:
                                    program.exerciseById(block.exerciseId),
                                suggestedWeightKg:
                                    session.suggestions[block.id] ?? 20,
                                setsTarget: block.maxSets,
                                repMin: block.repMin,
                                repMax: block.repMax,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (sessions.isNotEmpty)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: SafeArea(
                        child: SizedBox(
                          height: 60,
                          child: FilledButton.icon(
                            key: const Key('start-workout'),
                            onPressed: () {
                              final current = sessions[
                                  _currentPage.clamp(0, sessions.length - 1)];
                              _startWorkout(
                                program,
                                current.workout,
                                current.suggestions,
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Workout'),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Workout _nextWorkout(Program program, List<shared.WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return program.workouts.first;
    }

    final lastWorkoutId = sessions.first.workoutId;
    final lastIndex = program.workouts.indexWhere(
      (workout) => workout.id == lastWorkoutId,
    );
    if (lastIndex == -1) {
      return program.workouts.first;
    }
    return program.workouts[(lastIndex + 1) % program.workouts.length];
  }

  List<_PlannedSession> _plannedSessions(Program program, _TodayData data) {
    final dates = _scheduleDates(_horizonSessions);
    final suggestionCache = <String, Map<String, double>>{};

    var workout = _nextWorkout(program, data.sessions);
    final sessions = <_PlannedSession>[];
    for (var index = 0; index < dates.length; index += 1) {
      final suggestions = suggestionCache.putIfAbsent(
        workout.id,
        () => _suggestedWeights(program, workout, data),
      );
      sessions.add(
        _PlannedSession(
          date: dates[index],
          isToday: index == 0,
          workout: workout,
          suggestions: suggestions,
        ),
      );
      workout = _followingWorkout(program, workout);
    }
    return sessions;
  }

  List<DateTime> _scheduleDates(int count) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var offset = 0; offset < count; offset += 1)
        DateTime(today.year, today.month, today.day + offset),
    ];
  }

  Workout _followingWorkout(Program program, Workout current) {
    final index =
        program.workouts.indexWhere((workout) => workout.id == current.id);
    if (index == -1) {
      return program.workouts.first;
    }
    return program.workouts[(index + 1) % program.workouts.length];
  }

  String _dateLabel(_PlannedSession session) {
    if (session.isToday) {
      return 'Today: ${DateFormat.EEEE().format(session.date)}, '
          '${DateFormat.MMMd().format(session.date)}';
    }
    return '${DateFormat.E().format(session.date)}, '
        '${DateFormat.MMMd().format(session.date)}';
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
              previousEntry: data.previousEntryFor(block.exerciseId),
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

class _PlannedSession {
  const _PlannedSession({
    required this.date,
    required this.isToday,
    required this.workout,
    required this.suggestions,
  });

  final DateTime date;
  final bool isToday;
  final Workout workout;
  final Map<String, double> suggestions;
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index += 1)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: index == currentIndex ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? color
                  : color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
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
    return _entryFor(exerciseId, skip: 0);
  }

  shared.ExerciseEntry? previousEntryFor(String exerciseId) {
    return _entryFor(exerciseId, skip: 1);
  }

  shared.ExerciseEntry? _entryFor(String exerciseId, {required int skip}) {
    var matchesToSkip = skip;
    for (final session in sessions) {
      for (final entry in session.entries) {
        if (entry.exerciseId == exerciseId) {
          if (matchesToSkip == 0) {
            return entry;
          }
          matchesToSkip -= 1;
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
