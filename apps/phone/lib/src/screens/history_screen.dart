import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:program/program.dart';
import 'package:shared_models/shared_models.dart' as shared;

import '../providers/providers.dart';
import '../widgets/set_circle.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Sessions'),
              Tab(text: 'Trends'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _SessionsTab(ref: ref),
                const _TrendsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  const _SessionsTab({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(programProvider);
    return FutureBuilder<List<shared.WorkoutSession>>(
      future: ref.watch(sessionRepoProvider).listAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snapshot.data ?? const [];
        if (sessions.isEmpty) {
          return const _EmptyHistory();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final session = sessions[index];
            final workout = program.workoutById(session.workoutId);
            final totalReps = session.entries.fold<int>(
              0,
              (sum, entry) => sum + entry.sets.fold<int>(0, (a, set) => a + set.actualReps),
            );
            return Card(
              child: ListTile(
                minVerticalPadding: 16,
                title: Text(DateFormat.yMMMEd().format(session.startedAt.toLocal())),
                subtitle: Text('${workout.name} • ${session.entries.length} exercises • $totalReps total reps'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SessionDetailView(
                      session: session,
                      program: program,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SessionDetailView extends StatelessWidget {
  const SessionDetailView({
    super.key,
    required this.session,
    required this.program,
  });

  final shared.WorkoutSession session;
  final Program program;

  @override
  Widget build(BuildContext context) {
    final workout = program.workoutById(session.workoutId);
    return Scaffold(
      appBar: AppBar(title: Text(workout.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            DateFormat.yMMMMEEEEd().format(session.startedAt.toLocal()),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          for (final entry in session.entries)
            _SessionEntryCard(
              entry: entry,
              block: workout.blockById(entry.blockId),
              exercise: program.exerciseById(entry.exerciseId),
            ),
        ],
      ),
    );
  }
}

class _SessionEntryCard extends StatelessWidget {
  const _SessionEntryCard({
    required this.entry,
    required this.block,
    required this.exercise,
  });

  final shared.ExerciseEntry entry;
  final ExerciseBlock block;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text('${_formatWeight(entry.workingWeightKg)} kg • ${block.repMin}–${block.repMax} reps'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final set in entry.sets)
                  SetCircle(
                    state: set.isFailed ? SetState.failed : SetState.done,
                    reps: set.actualReps,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendsTab extends ConsumerStatefulWidget {
  const _TrendsTab();

  @override
  ConsumerState<_TrendsTab> createState() => _TrendsTabState();
}

class _TrendsTabState extends ConsumerState<_TrendsTab> {
  String? _exerciseId;

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(programProvider);
    _exerciseId ??= program.exercises.first.id;

    return FutureBuilder<List<shared.WorkoutSession>>(
      future: ref.watch(sessionRepoProvider).listAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snapshot.data ?? const [];
        if (sessions.isEmpty) {
          return const _EmptyHistory();
        }

        final exercise = program.exerciseById(_exerciseId!);
        final weightPoints = _weightPoints(sessions, exercise.id);
        final repPoints = _repPoints(sessions, exercise.id);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _exerciseId,
              decoration: const InputDecoration(labelText: 'Exercise'),
              items: [
                for (final exercise in program.exercises)
                  DropdownMenuItem(
                    value: exercise.id,
                    child: Text(exercise.name),
                  ),
              ],
              onChanged: (value) => setState(() => _exerciseId = value),
            ),
            const SizedBox(height: 16),
            _TrendChart(
              title: '${exercise.name} — working weight',
              points: weightPoints,
              unitLabel: 'kg',
            ),
            const SizedBox(height: 16),
            _TrendChart(
              title: '${exercise.name} — best reps',
              points: repPoints,
              unitLabel: 'reps',
            ),
          ],
        );
      },
    );
  }

  List<_TrendPoint> _weightPoints(
    List<shared.WorkoutSession> sessions,
    String exerciseId,
  ) {
    final chronological = sessions.reversed.toList();
    final points = <_TrendPoint>[];
    for (final session in chronological) {
      for (final entry in session.entries) {
        if (entry.exerciseId == exerciseId) {
          points.add(_TrendPoint(session.startedAt, entry.workingWeightKg));
        }
      }
    }
    return points;
  }

  List<_TrendPoint> _repPoints(
    List<shared.WorkoutSession> sessions,
    String exerciseId,
  ) {
    final chronological = sessions.reversed.toList();
    final points = <_TrendPoint>[];
    for (final session in chronological) {
      final reps = <int>[];
      for (final entry in session.entries) {
        if (entry.exerciseId == exerciseId) {
          for (final set in entry.sets) {
            if (!set.isWarmup && !set.isFailed) {
              reps.add(set.actualReps);
            }
          }
        }
      }
      if (reps.isNotEmpty) {
        points.add(_TrendPoint(session.startedAt, reps.reduce(math.max).toDouble()));
      }
    }
    return points;
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.title,
    required this.points,
    required this.unitLabel,
  });

  final String title;
  final List<_TrendPoint> points;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No data yet for $title'),
        ),
      );
    }

    final spots = [
      for (var index = 0; index < points.length; index += 1)
        FlSpot(index.toDouble(), points[index].value),
    ];
    final prSpots = _personalRecordSpots(spots);
    final minY = spots.map((spot) => spot.y).reduce(math.min);
    final maxY = spots.map((spot) => spot.y).reduce(math.max);
    final padding = math.max(1.0, (maxY - minY) * 0.15);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            Text('Gold dots mark PRs • $unitLabel'),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.8,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: math.max(1, spots.length - 1).toDouble(),
                  minY: minY - padding,
                  maxY: maxY + padding,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: theme.colorScheme.outlineVariant,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      color: theme.colorScheme.primary,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: prSpots,
                      barWidth: 0,
                      color: Colors.transparent,
                      dotData: FlDotData(
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 6,
                          color: Colors.amber,
                          strokeColor: theme.colorScheme.onSurface,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _personalRecordSpots(List<FlSpot> spots) {
    var best = double.negativeInfinity;
    final records = <FlSpot>[];
    for (final spot in spots) {
      if (spot.y > best) {
        records.add(spot);
        best = spot.y;
      }
    }
    return records;
  }
}

class _TrendPoint {
  const _TrendPoint(this.date, this.value);

  final DateTime date;
  final double value;
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 48),
            const SizedBox(height: 12),
            Text('No sessions yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/today'),
              child: const Text('Start from Today'),
            ),
          ],
        ),
      ),
    );
  }
}

extension _ProgramLookup on Program {
  Exercise exerciseById(String id) {
    return exercises.firstWhere(
      (exercise) => exercise.id == id,
      orElse: () => exercises.first,
    );
  }

  Workout workoutById(String id) {
    return workouts.firstWhere(
      (workout) => workout.id == id,
      orElse: () => workouts.first,
    );
  }
}

extension _WorkoutLookup on Workout {
  ExerciseBlock blockById(String id) {
    return blocks.firstWhere(
      (block) => block.id == id,
      orElse: () => blocks.first,
    );
  }
}

String _formatWeight(double weight) {
  if (weight == weight.roundToDouble()) {
    return weight.toStringAsFixed(0);
  }
  return weight.toStringAsFixed(1);
}
