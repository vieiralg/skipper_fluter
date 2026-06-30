import 'difficulty_rules.dart';
import 'level_definition.dart';

class DifficultyManager {
  static DifficultyRules getRules(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.tutorial:
        return const DifficultyRules(
          minGapX: 60,
          maxGapX: 160,
          maxClimbY: 100,
          maxDropY: 90,
          minVerticalRange: 60,
          maxAttempts: 30,
          minPlatformWidth: 96,
          maxPlatformWidth: 96,
        );
      case Difficulty.easy:
        return const DifficultyRules(
          minGapX: 55,
          maxGapX: 160,
          maxClimbY: 100,
          maxDropY: 90,
          minVerticalRange: 80,
          maxAttempts: 30,
          minPlatformWidth: 82,
          maxPlatformWidth: 82,
        );
      case Difficulty.easyPlus:
        return const DifficultyRules(
          minGapX: 80,
          maxGapX: 160,
          maxClimbY: 100,
          maxDropY: 90,
          minVerticalRange: 80,
          maxAttempts: 30,
          minPlatformWidth: 85,
          maxPlatformWidth: 120,
        );
      case Difficulty.medium:
        return const DifficultyRules(
          minGapX: 80,
          maxGapX: 110,
          maxClimbY: 60,
          maxDropY: 50,
          minVerticalRange: 120,
          maxAttempts: 30,
          minPlatformWidth: 80,
          maxPlatformWidth: 115,
        );
      case Difficulty.mediumPlus:
        return const DifficultyRules(
          minGapX: 80,
          maxGapX: 120,
          maxClimbY: 70,
          maxDropY: 55,
          minVerticalRange: 120,
          maxAttempts: 30,
          minPlatformWidth: 80,
          maxPlatformWidth: 110,
        );
      case Difficulty.hard:
        return const DifficultyRules(
          minGapX: 80,
          maxGapX: 125,
          maxClimbY: 75,
          maxDropY: 55,
          minVerticalRange: 120,
          maxAttempts: 35,
          minPlatformWidth: 80,
          maxPlatformWidth: 110,
        );
      case Difficulty.hardPlus:
        return const DifficultyRules(
          minGapX: 80,
          maxGapX: 130,
          maxClimbY: 80,
          maxDropY: 60,
          minVerticalRange: 120,
          maxAttempts: 35,
          minPlatformWidth: 80,
          maxPlatformWidth: 105,
        );
      case Difficulty.master:
        return const DifficultyRules(
          minGapX: 80,
          maxGapX: 130,
          maxClimbY: 80,
          maxDropY: 60,
          minVerticalRange: 120,
          maxAttempts: 40,
          minPlatformWidth: 80,
          maxPlatformWidth: 100,
        );
    }
  }

  static List<LevelDefinition> get builtInLevels => const [
    LevelDefinition(
      levelNumber: 1,
      title: 'Contar de 2 em 2',
      skipStep: 2,
      startValue: 2,
      endValue: 10,
      platformCount: 5,
      distractorCount: 0,
      difficulty: Difficulty.tutorial,
    ),
    LevelDefinition(
      levelNumber: 2,
      title: '2 até 20',
      skipStep: 2,
      startValue: 2,
      endValue: 20,
      platformCount: 10,
      distractorCount: 0,
      difficulty: Difficulty.easy,
    ),
  ];
}
