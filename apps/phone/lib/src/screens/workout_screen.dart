import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:program/program.dart';
import 'package:progression/progression.dart';
import 'package:shared_models/shared_models.dart' as shared;

import '../providers/providers.dart';
import '../services/notification_service.dart';
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

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with WidgetsBindingObserver {
  var _currentBlockIndex = 0;
  var _currentReps = 0;
  var _isResting = false;
  var _readyToFinish = false;
  late List<shared.ExerciseEntry> _entries;

  Timer? _restTimer;
  DateTime? _restEndAt;
  Duration _restInitial = Duration.zero;
  final ValueNotifier<Duration> _restRemaining = ValueNotifier(Duration.zero);
  bool _restWarned = false;
  bool _restCompleted = false;
  bool _restSheetOpen = false;
  NotificationService? _notifications;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _entries = _initialEntries();
    _restoreProgressFromEntries();
    _pageController = PageController(initialPage: _currentBlockIndex);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifications = ref.read(notificationServiceProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restTimer?.cancel();
    _restRemaining.dispose();
    _pageController?.dispose();
    final notifications = _notifications;
    if (notifications != null) {
      unawaited(notifications.cancelRestLiveActivity());
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resyncRest();
    }
  }

  @override
  void didUpdateWidget(covariant WorkoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id ||
        oldWidget.workout.id != widget.workout.id) {
      _entries = _initialEntries();
      _restoreProgressFromEntries();
      _jumpToCurrentBlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(programProvider);
    if (widget.workout.blocks.isEmpty) {
      return const Scaffold(body: Center(child: Text('No exercises planned.')));
    }

    final allSetsDone = _allSetsDone;

    final platesButton = FloatingActionButton.extended(
      key: const Key('plates-fab'),
      onPressed: _openPlateCalculator,
      icon: const Icon(Icons.album),
      label: const Text('Plates'),
    );
    final body = SafeArea(
      child: PageView.builder(
        key: const Key('exercise-pager'),
        controller: _pageController,
        physics: _isResting
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        onPageChanged: _onPageChanged,
        itemCount: widget.workout.blocks.length,
        itemBuilder: (context, index) =>
            _buildExercisePage(context, program, index),
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

  Widget _buildExercisePage(
    BuildContext context,
    Program program,
    int index,
  ) {
    final block = widget.workout.blocks[index];
    final exercise = program.exerciseById(block.exerciseId);
    final entry = _entries[index];
    final workingSets = _workingSets(entry);
    final warmupSets = _warmupSets(entry);
    final completedSets = workingSets.length;
    final progress = (index + completedSets / block.maxSets) /
        widget.workout.blocks.length;
    final isCurrent = index == _currentBlockIndex;
    final blockSetsDone = workingSets.length >= block.maxSets;
    final allSetsDone = _allSetsDone;
    final isLastBlock = index == widget.workout.blocks.length - 1;
    final repsValue = isCurrent ? _currentReps : _defaultRepsFor(block, entry);

    return ListView(
      key: PageStorageKey<String>('exercise-page-${block.id}'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
      children: [
        Text(
          'Exercise ${index + 1} of ${widget.workout.blocks.length} • ${widget.workout.name}',
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
                    onTap: () => _editWeight(index),
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
              if (warmupSets.isNotEmpty) ...[
                Text(
                  'Warm-ups',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final set in warmupSets)
                      _WarmupChip(reps: set.actualReps),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < block.maxSets; i += 1)
                    SetCircle(
                      state: _setCircleStateFor(workingSets, i, block.maxSets),
                      reps: i < workingSets.length
                          ? workingSets[i].actualReps
                          : null,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (!blockSetsDone) ...[
                Center(
                  child: NumericRepInput(
                    key: ValueKey('${block.id}-${workingSets.length}'),
                    initialValue: repsValue,
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
                  onShowTimer: _reopenRestSheet,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    key: const Key('add-warmup-set'),
                    onPressed: _isResting ? null : _recordWarmupSet,
                    icon: const Icon(Icons.whatshot_outlined),
                    label: const Text('Add warm-up set'),
                  ),
                ),
              ] else if (allSetsDone && isLastBlock) ...[
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
              ] else ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    allSetsDone
                        ? 'All sets done. Swipe to the last exercise to finish.'
                        : 'All sets done. Swipe to the next exercise.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _onPageChanged(int index) {
    if (index == _currentBlockIndex) {
      return;
    }
    setState(() {
      _currentBlockIndex = index;
      _currentReps = _defaultRepsForCurrentSet();
      _readyToFinish = _allSetsDone;
    });
  }

  void _syncPageController() {
    final controller = _pageController;
    if (controller == null || !controller.hasClients) {
      return;
    }
    if (controller.page?.round() == _currentBlockIndex) {
      return;
    }
    controller.animateToPage(
      _currentBlockIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _jumpToCurrentBlock() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _pageController;
      if (!mounted || controller == null || !controller.hasClients) {
        return;
      }
      controller.jumpToPage(_currentBlockIndex);
    });
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

  List<shared.SetLog> _workingSets(shared.ExerciseEntry entry) =>
      entry.sets.where((set) => !set.isWarmup).toList();

  List<shared.SetLog> _warmupSets(shared.ExerciseEntry entry) =>
      entry.sets.where((set) => set.isWarmup).toList();

  void _restoreProgressFromEntries() {
    _isResting = false;
    _readyToFinish = false;
    _currentBlockIndex = 0;
    _currentReps = 0;

    if (widget.workout.blocks.isEmpty || _entries.isEmpty) {
      return;
    }

    for (var index = 0; index < widget.workout.blocks.length; index += 1) {
      final block = widget.workout.blocks[index];
      final entry = _entries[index];
      if (_workingSets(entry).length < block.maxSets) {
        _currentBlockIndex = index;
        _currentReps = _defaultRepsFor(block, entry);
        return;
      }
    }

    _currentBlockIndex = widget.workout.blocks.length - 1;
    _readyToFinish = true;
    _currentReps = _defaultRepsForCurrentSet();
  }

  void _notifyEntriesChanged() {
    widget.onEntriesChanged
        ?.call(List<shared.ExerciseEntry>.unmodifiable(_entries));
  }

  SetState _setCircleStateFor(
    List<shared.SetLog> workingSets,
    int index,
    int maxSets,
  ) {
    if (index < workingSets.length) {
      return workingSets[index].isFailed ? SetState.failed : SetState.done;
    }
    if (index == workingSets.length && workingSets.length < maxSets) {
      return SetState.inProgress;
    }
    return SetState.pending;
  }

  bool get _allSetsDone {
    if (_entries.isEmpty) {
      return false;
    }
    for (var index = 0; index < widget.workout.blocks.length; index += 1) {
      if (_workingSets(_entries[index]).length <
          widget.workout.blocks[index].maxSets) {
        return false;
      }
    }
    return true;
  }

  Future<void> _editWeight(int index) async {
    final entry = _entries[index];
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
      _entries[index] = entry.copyWith(workingWeightKg: value);
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
      _readyToFinish = _allSetsDone;
    });
    _notifyEntriesChanged();

    unawaited(_signalSetCompleted(setLog, block.id));
    if (setLog.isFailed || setLog.actualReps < setLog.targetRepMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Below the target minimum - repeat this next time to trigger a 10% reduction.'),
        ),
      );
    }

    if (!_hasMoreWorkAfterCurrentSet()) {
      setState(() => _readyToFinish = true);
      return;
    }

    _startRest(Duration(seconds: block.restMinSeconds));
  }

  Future<void> _recordWarmupSet() async {
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
      isWarmup: true,
      isFailed: false,
    );

    setState(() {
      _entries[_currentBlockIndex] =
          entry.copyWith(sets: [...entry.sets, setLog]);
    });
    _notifyEntriesChanged();

    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
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
    if (_workingSets(entry).length < block.maxSets) {
      return true;
    }
    return _currentBlockIndex < widget.workout.blocks.length - 1;
  }

  NotificationService get _notificationService =>
      _notifications ?? ref.read(notificationServiceProvider);

  void _startRest(Duration duration) {
    _restTimer?.cancel();
    _restCompleted = false;
    _restInitial = duration;
    _restEndAt = DateTime.now().add(duration);
    _restRemaining.value = duration;
    _restWarned = duration.inSeconds <= 10;
    setState(() => _isResting = true);

    if (duration <= Duration.zero) {
      _completeRest();
      return;
    }

    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) => _restTick());
    final endUtc = _restEndAt!.toUtc();
    unawaited(_notificationService.showRestLiveActivity(endUtc));
    unawaited(_notificationService.scheduleRestComplete(endUtc));
    _showRestSheet();
  }

  void _restTick() {
    final endAt = _restEndAt;
    if (endAt == null || _restCompleted) {
      return;
    }
    final remaining = endAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _restRemaining.value = Duration.zero;
      _completeRest();
      return;
    }
    _restRemaining.value = remaining;
    if (!_restWarned && remaining.inSeconds <= 10) {
      _restWarned = true;
      unawaited(_playTenSecondSignal());
    }
  }

  void _resyncRest() {
    if (!_isResting || _restCompleted) {
      return;
    }
    final endAt = _restEndAt;
    if (endAt == null) {
      return;
    }
    final remaining = endAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _restRemaining.value = Duration.zero;
      _completeRest();
    } else {
      _restRemaining.value = remaining;
    }
  }

  void _adjustRest(Duration delta) {
    if (_restCompleted) {
      return;
    }
    final now = DateTime.now();
    var newEnd = (_restEndAt ?? now).add(delta);
    if (newEnd.isBefore(now)) {
      newEnd = now;
    }
    _restEndAt = newEnd;
    final remaining = newEnd.difference(now);
    _restRemaining.value = remaining.isNegative ? Duration.zero : remaining;
    _restWarned = _restRemaining.value.inSeconds <= 10;

    if (_restRemaining.value <= Duration.zero) {
      _completeRest();
      return;
    }
    final endUtc = newEnd.toUtc();
    unawaited(_notificationService.showRestLiveActivity(endUtc));
    unawaited(_notificationService.scheduleRestComplete(endUtc));
  }

  void _completeRest() {
    if (_restCompleted) {
      return;
    }
    _restCompleted = true;
    _restTimer?.cancel();
    _restTimer = null;
    unawaited(_notificationService.cancelRestLiveActivity());
    unawaited(_notificationService.cancelRestComplete());
    unawaited(_playCompleteSignal());
    _dismissRestSheet();
    _advanceAfterRest();
  }

  void _skipRest() {
    if (_restCompleted) {
      return;
    }
    _restCompleted = true;
    _restTimer?.cancel();
    _restTimer = null;
    unawaited(_notificationService.cancelRestLiveActivity());
    unawaited(_notificationService.cancelRestComplete());
    _dismissRestSheet();
    _advanceAfterRest();
  }

  void _showRestSheet() {
    if (_restSheetOpen) {
      return;
    }
    _restSheetOpen = true;
    showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      showDragHandle: true,
      builder: (context) => RestTimerWidget(
        initial: _restInitial,
        remaining: _restRemaining,
        onAdjust: _adjustRest,
        onSkip: _skipRest,
      ),
    ).whenComplete(() {
      _restSheetOpen = false;
    });
  }

  void _dismissRestSheet() {
    if (_restSheetOpen && mounted) {
      Navigator.of(context).pop();
    }
    _restSheetOpen = false;
  }

  void _reopenRestSheet() {
    if (_isResting && !_restCompleted && !_restSheetOpen) {
      _showRestSheet();
    }
  }

  Future<void> _playTenSecondSignal() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
    await ref.read(watchBridgeProvider).triggerHaptic();
  }

  Future<void> _playCompleteSignal() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    await ref.read(watchBridgeProvider).triggerHaptic();
  }

  void _advanceAfterRest() {
    if (!mounted) {
      return;
    }
    final block = widget.workout.blocks[_currentBlockIndex];
    final entry = _entries[_currentBlockIndex];
    setState(() {
      _isResting = false;
      if (_workingSets(entry).length >= block.maxSets) {
        if (_currentBlockIndex < widget.workout.blocks.length - 1) {
          _currentBlockIndex += 1;
        } else {
          _readyToFinish = true;
        }
      }
      _currentReps = _defaultRepsForCurrentSet();
    });
    _syncPageController();
  }

  int _defaultRepsForCurrentSet() {
    final block = widget.workout.blocks[_currentBlockIndex];
    final entry = _entries[_currentBlockIndex];
    return _defaultRepsFor(block, entry);
  }

  int _defaultRepsFor(ExerciseBlock block, shared.ExerciseEntry entry) {
    final working = _workingSets(entry);
    if (working.isEmpty) {
      return block.repMax;
    }
    return working.last.actualReps;
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

    final sessionRepo = ref.read(sessionRepoProvider);
    final priorSessions = await sessionRepo.listAll();
    await sessionRepo.insert(completed);
    await _updateProgressionStates(completedAt, priorSessions);

    if (!mounted) {
      return;
    }
    final navigator = Navigator.of(context);
    widget.onFinished?.call();
    navigator.pushNamedAndRemoveUntil('/history', (route) => false);
  }

  Future<void> _updateProgressionStates(
    DateTime atUtc,
    List<shared.WorkoutSession> priorSessions,
  ) async {
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
        previousEntry: _previousEntryFor(entry.exerciseId, priorSessions),
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

      final fromKg = entry.workingWeightKg;
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

  shared.ExerciseEntry? _previousEntryFor(
    String exerciseId,
    List<shared.WorkoutSession> sessions,
  ) {
    for (final session in sessions) {
      for (final entry in session.entries) {
        if (entry.exerciseId == exerciseId) {
          return entry;
        }
      }
    }
    return null;
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
    required this.onShowTimer,
  });

  final bool isResting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onShowTimer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isResting ? colors.surfaceContainerHighest : colors.primary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: const Key('done-set'),
        borderRadius: BorderRadius.circular(18),
        onTap: isResting ? onShowTimer : onTap,
        onLongPress: isResting ? null : onLongPress,
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: Center(
            child: Text(
              isResting ? 'Resting… (tap to view)' : 'Done Set',
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

class _WarmupChip extends StatelessWidget {
  const _WarmupChip({required this.reps});

  final int reps;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surfaceContainerHighest,
        border: Border.all(color: colors.outlineVariant, width: 2),
      ),
      child: Text(
        '$reps',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
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
