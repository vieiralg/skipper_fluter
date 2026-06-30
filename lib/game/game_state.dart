import 'package:flutter/foundation.dart';
import 'levels/generated_level.dart';

class GameState extends ChangeNotifier {
  final GeneratedLevel levelData;
  int _currentHP;
  final List<bool> starsCollected;

  GameState({required this.levelData, int initialHP = 3})
      : _currentHP = initialHP,
        starsCollected = List.filled(levelData.correctSequence.length, false);

  int get currentHP => _currentHP;

  int collectedIndex = 0;
  final List<int> collectedNumbers = [];
  int lastPlatformIndex = 0;
  bool isPaused = false;
  bool isGameOver = false;
  bool isVictory = false;
  Duration elapsedTime = Duration.zero;
  bool hasSeenTutorial = false;

  List<int> get correctSequence =>
      levelData.correctSequence;

  void loseHP() {
    _currentHP--;
    notifyListeners();
    if (_currentHP <= 0) {
      isGameOver = true;
      notifyListeners();
    }
  }

  void collectStar(int number) {
    if (collectedIndex >= correctSequence.length) return;
    if (number != correctSequence[collectedIndex]) return;

    collectedNumbers.add(number);
    starsCollected[collectedIndex] = true;
    collectedIndex++;
    notifyListeners();
    if (collectedIndex >= correctSequence.length) {
      isVictory = true;
      notifyListeners();
    }
  }

  bool isCorrectStar(int number) {
    if (collectedIndex >= correctSequence.length) return false;
    return number == correctSequence[collectedIndex];
  }

  void setPaused(bool paused) {
    isPaused = paused;
    notifyListeners();
  }

  void reset() {
    _currentHP = 3;
    collectedIndex = 0;
    collectedNumbers.clear();
    for (int i = 0; i < starsCollected.length; i++) {
      starsCollected[i] = false;
    }
    lastPlatformIndex = 0;
    isPaused = false;
    isGameOver = false;
    isVictory = false;
    elapsedTime = Duration.zero;
    notifyListeners();
  }
}
