import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:program/program.dart';
import 'package:progression/progression.dart';
import 'package:shared_models/shared_models.dart' as shared;

import '../providers/providers.dart';
import '../widgets/exercise_card.dart';
import '../widgets/numeric_rep_input.dart';
import '../widgets/plate_calculator.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/set_circle.dart';

class WorkoutStartPrompt extends StatelessWidget {
  const WorkoutStartPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, size: 48),
            const SizedBox(height: 16),
            Text(
              'No workout in progress',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Start today’s workout from the Today tab.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/today'),
              child: const Text('Go to Today'),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutTab extends ConsumerWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    if (activeWorkout == null) {
      return const WorkoutStartPrompt();
    }

    return WorkoutScreen(
      key: ValueKey(activeWorkout.session.id),
      session: activeWorkout.session,
      workout: activeWorkout.workout,
      suggestedWeightsKg: activeWorkout.suggestedWeightsKg,
      initialEntries: activeWorkout.entries,
      embedded: true,
      onEntriesChanged: (entries) {
        ref.read(activeWorkoutProvider.notifier).updateEntries(entries);
      },
      onFinished: () {
        ref.read(activeWorkoutProvider.notifier).clear();
      },
    );
  }
}

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({
    super.key,
    required this.session,
    required this.workout,
    required this.suggestedWeightsKg,
    this.initialEntries = const <shared.ExerciseEntry>[],
    this.embedded = false,
    this.onEntriesChanged,
    this.onFinished,
  });

  final shared.WorkoutSession session;
  final Workout workout;
  final Map<String, double> suggestedWeightsKg;
  final List<shared.ExerciseEntry> initialEntries;
  final bool embedded;
  final ValueChanged<List<shared.ExerciseEntry>>? onEntriesChanged;
  final VoidCallback? onFinished;

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  var _currentBlockIndex = 0;
  var _currentSetIndex = 0;
  var _currentReps = 0;
  var _isResting = false;
  var _readyToFinish = false;
  late List<shared.ExerciseEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _initialEntries();
    _restoreProgressFromEntries();
  }

  @override
  void didUpdateWidget(covariant WorkoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id ||
        oldWidget.workout.id != widget.workout.id) {
      _entries = _initialEntries();
      _restoreProgressFromEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(programProvider);
    if (widget.workout.blocks.isEmpty) {
      return const Scaffold(body: Center(child: Text('No exercises planned.')));
    }

    final block = widget.workout.blocks[_currentBlockIndex];
    final exercise = program.exerciseById(block.exerciseId);
    final entry = _entries[_currentBlockIndex];
    final completedSets = entry.sets.length;
    final progress = (_currentBlockIndex + completedSets / block.maxSets) /
        widget.workout.blocks.length;
    final allSetsDone = _allSetsDone;

    final platesButton = FloatingActionButton.extended(
      key: const Key('plates-fab'),
      onPressed: _openPlateCalculator,
      icon: const Icon(Icons.album),
      label: const Text('Plates'),
    );
    final body = SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          Text(
            'Exercise ${_currentBlockIndex + 1} of ${widget.workout.blocks.length} • ${widget.workout.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress.clamp(0, 1).toDouble()),
          const SizedBox(height: 16),
          ExerciseCard(
            block: block,
            exercise: exercise,
            suggestedWeightKg: entry.workingWeightKg,
            setsTarget: block.maxSets,
            repMin: block.repMin,
            repMax: block.repMax,
          ),
          const SizedBox(height: 8),
          _WorkoutCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                    ),
                    InkWell(
                      key: const Key('working-weight'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _editWeight(entry),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(
                          '${_formatWeight(entry.workingWeightKg)} kg',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${block.repMin}–${block.repMax} reps • rest ${_minutes(block.restMinSeconds)}–${_minutes(block.restMaxSeconds)} min',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var index = 0; index < block.maxSets; index += 1)
                      SetCircle(
                        state: _setCircleState(entry, index),
                        reps: index < entry.sets.length
                            ? entry.sets[index].actualReps
                            : null,
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (!allSetsDone) ...[
                  Center(
                    child: NumericRepInput(
                      key: ValueKey('${block.id}-$_currentSetIndex'),
                      initialValue: _currentReps,
                      onChanged: (value) => _currentReps = value,
                      onDone: (_) => _recordSet(failed: false),
                      onLongPressFail: (_) => _recordSet(failed: true),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DoneSetButton(
                    isResting: _isResting,
                    onTap: () => _recordSet(failed: false),
                    onLongPress: () => _recordSet(failed: true),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton.icon(
                      key: const Key('finish-workout'),
                      onPressed: _finishWorkout,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Finish Workout'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return Stack(
        children: [
          body,
          Positioned(
            right: 16,
            bottom: 16,
            child: platesButton,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          if (allSetsDone)
            TextButton(
              key: const Key('finish-workout-action'),
              onPressed: _finishWorkout,
              child: const Text('Finish'),
            ),
        ],
      ),
      floatingActionButton: platesButton,
      body: body,
    );
  }

  List<shared.ExerciseEntry> _initialEntries() {
    final entriesByBlock = {
      for (final entry in widget.initialEntries) entry.blockId: entry,
    };

    return [
      for (final block in widget.workout.blocks)
        entriesByBlock[block.id] ??
            shared.ExerciseEntry(
              blockId: block.id,
              exerciseId: block.exerciseId,
              workingWeightKg: widget.suggestedWeightsKg[block.id] ?? 20,
              suggestionAppliedKg: widget.suggestedWeightsKg[block.id],
            ),
    ];
  }

  void _restoreProgressFromEntries() {
    _isResting = false;
    _readyToFinish = false;
    _currentBlockIndex = 0;
    _currentSetIndex = 0;
    _currentReps = 0;

    if (widget.workout.blocks.isEmpty || _entries.isEmpty) {
      return;
    }

    for (var index = 0; index < widget.workout.blocks.length; index += 1) {
      final block = widget.workout.blocks[index];
      final entry = _entries[index];
      if (entry.sets.length < block.maxSets) {
        _currentBlockIndex = index;
        _currentSetIndex = entry.sets.length;
        _currentReps = _defaultRepsFor(block, entry);
        return;
      }
    }

    _currentBlockIndex = widget.workout.blocks.length - 1;
    _currentSetIndex = _entries[_currentBlockIndex].sets.length;
    _readyToFinish = true;
    _currentReps = _defaultRepsForCurrentSet();
  }

  void _notifyEntriesChanged() {
    widget.onEntriesChanged
        ?.call(List<shared.ExerciseEntry>.unmodifiable(_entries));
  }

  SetState _setCircleState(shared.ExerciseEntry entry, int index) {
    if (index < entry.sets.length) {
      return entry.sets[index].isFailed ? SetState.failed : SetState.done;
    }
    if (index == _currentSetIndex && !_readyToFinish) {
      return SetState.inProgress;
    }
    return SetState.pending;
  }

  bool get _allSetsDone {
    if (_entries.isEmpty) {
      return false;
    }
    for (var index = 0; index < widget.workout.blocks.length; index += 1) {
      if (_entries[index].sets.length < widget.workout.blocks[index].maxSets) {
        return false;
      }
    }
    return true;
  }

  Future<void> _editWeight(shared.ExerciseEntry entry) async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) => _WeightDialog(
        initialWeightKg: entry.workingWeightKg,
      ),
    );

    if (value == null || !mounted) {
      return;
    }
    setState(() {
      _entries[_currentBlockIndex] = entry.copyWith(workingWeightKg: value);
    });
    _notifyEntriesChanged();
  }

  Future<void> _recordSet({required bool failed}) async {
    if (_isResting || _allSetsDone) {
      return;
    }

    final block = widget.workout.blocks[_currentBlockIndex];
    final entry = _entries[_currentBlockIndex];
    final setLog = shared.SetLog(
      targetRepMin: block.repMin,
      targetRepMax: block.repMax,
      actualReps: _currentReps,
      completedAt: DateTime.now().toUtc(),
      isWarmup: false,
      isFailed: failed,
    );
    final updatedEntry = entry.copyWith(sets: [...entry.sets, setLog]);

    setState(() {
      _entries[_currentBlockIndex] = updatedEntry;
      _currentSetIndex = updatedEntry.sets.length;
      _readyToFinish = _allSetsDone;
    });
    _notifyEntriesChanged();

    unawaited(_signalSetCompleted(setLog, block.id));
    if (ref
        .read(progressionEngineProvider)
        .shouldDeloadRemainingSets(updatedEntry, block)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Last set under range — consider dropping remaining sets ~10%.'),
        ),
      );
    }

    if (!_hasMoreWorkAfterCurrentSet()) {
      setState(() => _readyToFinish = true);
      return;
    }

    setState(() => _isResting = true);
    await _showRestTimer(Duration(seconds: block.restMinSeconds));
  }

  Future<void> _signalSetCompleted(shared.SetLog setLog, String blockId) async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
    await ref.read(watchBridgeProvider).sendSetCompleted(
          setLog,
          sessionId: widget.session.id,
          blockId: blockId,
        );
    await ref.read(watchBridgeProvider).triggerHaptic();
  }

  bool _hasMoreWorkAfterCurrentSet() {
    final block = widget.workout.blocks[_currentBlockIndex];
    final entry = _entries[_currentBlockIndex];
    if (entry.sets.length < block.maxSets) {
      return true;
    }
    return _currentBlockIndex < widget.workout.blocks.length - 1;
  }

  Future<void> _showRestTimer(Duration duration) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => RestTimerWidget(
        initial: duration,
        onComplete: () {
          Navigator.of(context).pop();
          _advanceAfterRest();
        },
        onSkip: () {
          Navigator.of(context).pop();
          _advanceAfterRest();
        },
      ),
    );
  }

  void _advanceAfterRest() {
    if (!mounted) {
      return;
    }
    final block = widget.workout.blocks[_currentBlockIndex];
    final entry = _entries[_currentBlockIndex];
    setState(() {
      _isResting = false;
      if (entry.sets.length < block.maxSets) {
        _currentSetIndex = entry.sets.length;
      } else if (_currentBlockIndex < widget.workout.blocks.length - 1) {
        _currentBlockIndex += 1;
        _currentSetIndex = 0;
      } else {
        _readyToFinish = true;
      }
      _currentReps = _defaultRepsForCurrentSet();
    });
  }

  int _defaultRepsForCurrentSet() {
    final block = widget.workout.blocks[_currentBlockIndex];
    final entry = _entries[_currentBlockIndex];
    return _defaultRepsFor(block, entry);
  }

  int _defaultRepsFor(ExerciseBlock block, shared.ExerciseEntry entry) {
    if (entry.sets.isEmpty) {
      return block.repMax;
    }
    return entry.sets.last.actualReps;
  }

  Future<void> _openPlateCalculator() async {
    final settings = ref.read(settingsRepoProvider);
    final barWeight = await settings.getDouble('bar_weight_kg') ?? 20;
    final inventory =
        _decodeInventory(await settings.getString('plate_inventory'));
    if (!mounted) {
      return;
    }
    final entry = _entries[_currentBlockIndex];
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(12),
        child: PlateCalculator(
          weightKg: entry.workingWeightKg,
          barWeightKg: barWeight,
          platePairsAvailable: inventory,
        ),
      ),
    );
  }

  Map<double, int> _decodeInventory(String? raw) {
    if (raw == null) {
      return _defaultInventory;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      return {
        for (final entry in decoded.entries)
          if (double.tryParse(entry.key) != null && entry.value is num)
            double.parse(entry.key): (entry.value! as num).toInt(),
      };
    } catch (_) {
      return _defaultInventory;
    }
  }

  Future<void> _finishWorkout() async {
    if (!_allSetsDone && !_readyToFinish) {
      return;
    }
    final completedAt = DateTime.now().toUtc();
    final completed = widget.session.copyWith(
      completedAt: completedAt,
      entries: List<shared.ExerciseEntry>.unmodifiable(_entries),
    );

    await ref.read(sessionRepoProvider).insert(completed);
    await _updateProgressionStates(completedAt);

    if (!mounted) {
      return;
    }
    final navigator = Navigator.of(context);
    widget.onFinished?.call();
    navigator.pushNamedAndRemoveUntil('/history', (route) => false);
  }

  Future<void> _updateProgressionStates(DateTime atUtc) async {
    final stateDao = ref.read(exerciseStateRepoProvider);
    final engine = ref.read(progressionEngineProvider);
    final program = ref.read(programProvider);

    for (var index = 0; index < widget.workout.blocks.length; index += 1) {
      final block = widget.workout.blocks[index];
      final entry = _entries[index];
      final state = await stateDao.get(entry.exerciseId);
      final suggestion = engine.computeNextSuggestion(
        state: state,
        lastEntry: entry,
        block: block,
        exercise: program.exerciseById(entry.exerciseId),
      );

      final reason = switch (suggestion.reason) {
        SuggestionReason.increase => shared.WeightChangeReason.increment,
        SuggestionReason.deload => shared.WeightChangeReason.deload,
        SuggestionReason.firstTime || SuggestionReason.hold => null,
      };
      if (reason == null || suggestion.weightKg == entry.workingWeightKg) {
        continue;
      }

      final fromKg = state?.currentWorkingWeightKg ?? entry.workingWeightKg;
      final history = [
        ...?state?.history,
        shared.WeightChange(
          fromKg: fromKg,
          toKg: suggestion.weightKg,
          atUtc: atUtc,
          reason: reason,
        ),
      ];
      await stateDao.upsert(
        shared.ExerciseState(
          exerciseId: entry.exerciseId,
          currentWorkingWeightKg: suggestion.weightKg,
          lastUpdatedAt: atUtc,
          history: history,
        ),
      );
    }
  }

  static final _defaultInventory = <double, int>{
    25: 0,
    20: 1,
    15: 1,
    10: 2,
    5: 2,
    2.5: 2,
    1.25: 2,
  };

  static String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toStringAsFixed(0);
    }
    return weight.toStringAsFixed(1);
  }

  static String _minutes(int seconds) {
    final minutes = seconds / 60;
    if (minutes == minutes.roundToDouble()) {
      return minutes.toStringAsFixed(0);
    }
    return minutes.toStringAsFixed(1);
  }
}

class _WeightDialog extends StatefulWidget {
  const _WeightDialog({required this.initialWeightKg});

  final double initialWeightKg;

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatWeight(widget.initialWeightKg),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Working weight'),
      content: TextField(
        key: const Key('weight-field'),
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
        decoration: const InputDecoration(suffixText: 'kg'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final parsed =
                double.tryParse(_controller.text.replaceAll(',', '.'));
            Navigator.of(context).pop(parsed);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  static String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toStringAsFixed(0);
    }
    return weight.toStringAsFixed(1);
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _DoneSetButton extends StatelessWidget {
  const _DoneSetButton({
    required this.isResting,
    required this.onTap,
    required this.onLongPress,
  });

  final bool isResting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isResting ? colors.surfaceContainerHighest : colors.primary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: const Key('done-set'),
        borderRadius: BorderRadius.circular(18),
        onTap: isResting ? null : onTap,
        onLongPress: isResting ? null : onLongPress,
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: Center(
            child: Text(
              isResting ? 'Resting…' : 'Done Set',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        isResting ? colors.onSurfaceVariant : colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
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
}
