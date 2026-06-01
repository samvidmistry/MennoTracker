import 'package:program/program.dart';
import 'package:shared_models/shared_models.dart';

import 'config.dart';

enum SuggestionReason { firstTime, increase, hold, deload }

class SuggestedSet {
  final double weightKg;
  final SuggestionReason reason;

  const SuggestedSet({required this.weightKg, required this.reason});
}

class ProgressionEngine {
  final ProgressionConfig config;

  const ProgressionEngine({this.config = const ProgressionConfig()});

  /// Suggests the working weight for the next session of this exercise.
  SuggestedSet computeNextSuggestion({
    required ExerciseState? state,
    required ExerciseEntry? lastEntry,
    required ExerciseBlock block,
    required Exercise exercise,
    ExerciseEntry? previousEntry,
  }) {
    if (state == null && lastEntry == null) {
      return SuggestedSet(
        weightKg: exercise.isBarbell ? 20.0 : exercise.smallestPlatePairKg,
        reason: SuggestionReason.firstTime,
      );
    }

    if (lastEntry == null) {
      return SuggestedSet(
        weightKg: state!.currentWorkingWeightKg,
        reason: SuggestionReason.hold,
      );
    }

    if (_stateAlreadyReflectsEntry(state, lastEntry)) {
      return SuggestedSet(
        weightKg: state!.currentWorkingWeightKg,
        reason: SuggestionReason.hold,
      );
    }

    final currentWeightKg = lastEntry.workingWeightKg;

    if (config.consecutiveMissesTriggerDeload &&
        previousEntry != null &&
        missedMinimumReps(lastEntry) &&
        missedMinimumReps(previousEntry)) {
      return SuggestedSet(
        weightKg: snapToPlateDown(
          currentWeightKg * (1 - config.deloadPercent),
          exercise.smallestPlatePairKg,
        ),
        reason: SuggestionReason.deload,
      );
    }

    if (hitTopOfRangeOnAllSets(lastEntry, block)) {
      return SuggestedSet(
        weightKg: snapToPlateUp(
          currentWeightKg + exercise.defaultIncrementKg,
          exercise.smallestPlatePairKg,
        ),
        reason: SuggestionReason.increase,
      );
    }

    return SuggestedSet(
      weightKg: currentWeightKg,
      reason: SuggestionReason.hold,
    );
  }

  bool hitTopOfRangeOnAllSets(ExerciseEntry entry, ExerciseBlock block) {
    final hardSets = _hardSets(entry);
    if (hardSets.length < block.maxSets) {
      return false;
    }
    for (final set in hardSets) {
      if (set.isFailed || set.actualReps < set.targetRepMax) {
        return false;
      }
    }
    return true;
  }

  bool missedMinimumReps(ExerciseEntry entry) {
    for (final set in _hardSets(entry)) {
      if (set.isFailed || set.actualReps < set.targetRepMin) {
        return true;
      }
    }
    return false;
  }

  /// Snaps a weight UP to the nearest multiple of `smallestPlatePairKg`.
  /// e.g. snapToPlateUp(82.0, 2.5) -> 82.5; snapToPlateUp(80.0, 2.5) -> 80.0.
  static double snapToPlateUp(double weightKg, double smallestPlatePairKg) {
    if (smallestPlatePairKg <= 0) return weightKg;
    final multiplier = (weightKg / smallestPlatePairKg).ceil();
    return double.parse((multiplier * smallestPlatePairKg).toStringAsFixed(3));
  }

  /// Snaps a weight DOWN. Used for deload.
  static double snapToPlateDown(double weightKg, double smallestPlatePairKg) {
    if (smallestPlatePairKg <= 0) return weightKg;
    final multiplier = (weightKg / smallestPlatePairKg).floor();
    return double.parse((multiplier * smallestPlatePairKg).toStringAsFixed(3));
  }

  bool _stateAlreadyReflectsEntry(
    ExerciseState? state,
    ExerciseEntry lastEntry,
  ) {
    if (state == null) {
      return false;
    }
    final lastSetCompletedAt = _lastSetCompletedAt(lastEntry);
    if (lastSetCompletedAt == null) {
      return false;
    }
    return !state.lastUpdatedAt.toUtc().isBefore(lastSetCompletedAt.toUtc());
  }

  DateTime? _lastSetCompletedAt(ExerciseEntry entry) {
    DateTime? latest;
    for (final set in entry.sets) {
      if (latest == null || set.completedAt.isAfter(latest)) {
        latest = set.completedAt;
      }
    }
    return latest;
  }

  List<SetLog> _hardSets(ExerciseEntry entry) {
    return [
      for (final set in entry.sets)
        if (!set.isWarmup) set,
    ];
  }
}
