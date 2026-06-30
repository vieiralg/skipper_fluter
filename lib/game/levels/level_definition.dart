enum Difficulty {
  tutorial,
  easy,
  easyPlus,
  medium,
  mediumPlus,
  hard,
  hardPlus,
  master,
}

class LevelDefinition {
  final int levelNumber;
  final String title;
  final int skipStep;
  final int startValue;
  final int endValue;
  final int platformCount;
  final int distractorCount;
  final Difficulty difficulty;

  const LevelDefinition({
    required this.levelNumber,
    required this.title,
    required this.skipStep,
    required this.startValue,
    required this.endValue,
    required this.platformCount,
    required this.distractorCount,
    required this.difficulty,
  });

  int get correctCount => platformCount - distractorCount;
}
