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
  }) {
    if (state == null && lastEntry == null) {
      // Placeholder only: first-time users should override this with a real working weight.
      return SuggestedSet(
        weightKg: exercise.isBarbell ? 20.0 : exercise.smallestPlatePairKg,
        reason: SuggestionReason.firstTime,
      );
    }

    final currentWeightKg =
        state?.currentWorkingWeightKg ?? lastEntry!.workingWeightKg;

    if (lastEntry == null) {
      return SuggestedSet(
        weightKg: currentWeightKg,
        reason: SuggestionReason.hold,
      );
    }

    final topSet = _firstHardSuccessfulSet(lastEntry);
    if (topSet == null) {
      return SuggestedSet(
        weightKg: currentWeightKg,
        reason: SuggestionReason.hold,
      );
    }

    // Safety wins over progression: if any later hard set crashed, the load is over target.
    if (config.repsBelowMinTriggersDeload &&
        shouldDeloadRemainingSets(lastEntry, block)) {
      return SuggestedSet(
        weightKg: snapToPlateDown(
          currentWeightKg * (1 - config.deloadPercent),
          exercise.smallestPlatePairKg,
        ),
        reason: SuggestionReason.deload,
      );
    }

    final bumpThreshold = config.bumpThresholdFor(block.repMin, block.repMax);
    if (bumpThreshold != null && topSet.actualReps >= bumpThreshold) {
      return SuggestedSet(
        weightKg: snapToPlateUp(
          currentWeightKg * (1 + config.incrementPercent),
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

  bool shouldDeloadRemainingSets(
      ExerciseEntry currentEntry, ExerciseBlock block) {
    if (currentEntry.sets.length <= 1) return false;
    for (var i = 1; i < currentEntry.sets.length; i++) {
      final set = currentEntry.sets[i];
      if (set.isWarmup) continue;
      if (set.isFailed || set.actualReps < block.repMin) return true;
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

  SetLog? _firstHardSuccessfulSet(ExerciseEntry entry) {
    for (final set in entry.sets) {
      if (set.isWarmup || set.isFailed) continue;
      return set;
    }
    return null;
  }
}
