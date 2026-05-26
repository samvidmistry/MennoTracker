class RepRangeThreshold {
  final int repMin;
  final int repMax;
  final int bumpAtReps;

  const RepRangeThreshold({
    required this.repMin,
    required this.repMax,
    required this.bumpAtReps,
  });
}

class ProgressionConfig {
  final List<RepRangeThreshold> thresholds;
  final double incrementPercent;
  final double deloadPercent;
  final bool repsBelowMinTriggersDeload;

  const ProgressionConfig({
    this.thresholds = const [
      RepRangeThreshold(repMin: 5, repMax: 8, bumpAtReps: 10),
      RepRangeThreshold(repMin: 6, repMax: 10, bumpAtReps: 12),
      RepRangeThreshold(repMin: 8, repMax: 12, bumpAtReps: 14),
    ],
    this.incrementPercent = 0.025,
    this.deloadPercent = 0.10,
    this.repsBelowMinTriggersDeload = true,
  });

  int? bumpThresholdFor(int repMin, int repMax) {
    for (final threshold in thresholds) {
      if (threshold.repMin == repMin && threshold.repMax == repMax) {
        return threshold.bumpAtReps;
      }
    }

    RepRangeThreshold? best;
    var bestDist = 999;
    final mid = (repMin + repMax) / 2;
    for (final threshold in thresholds) {
      final thresholdMid = (threshold.repMin + threshold.repMax) / 2;
      final distance = (thresholdMid - mid).abs().round();
      if (distance < bestDist) {
        bestDist = distance;
        best = threshold;
      }
    }
    return best?.bumpAtReps;
  }
}
