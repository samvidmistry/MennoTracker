class ProgressionConfig {
  final double deloadPercent;
  final bool consecutiveMissesTriggerDeload;

  const ProgressionConfig({
    this.deloadPercent = 0.10,
    this.consecutiveMissesTriggerDeload = true,
  });
}
