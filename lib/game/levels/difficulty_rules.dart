class DifficultyRules {
  final double minGapX;
  final double maxGapX;
  final double maxClimbY;
  final double maxDropY;
  final double minVerticalRange;
  final int maxAttempts;
  final double minPlatformWidth;
  final double maxPlatformWidth;

  const DifficultyRules({
    required this.minGapX,
    required this.maxGapX,
    required this.maxClimbY,
    required this.maxDropY,
    required this.minVerticalRange,
    this.maxAttempts = 30,
    this.minPlatformWidth = 80,
    this.maxPlatformWidth = 120,
  });
}
