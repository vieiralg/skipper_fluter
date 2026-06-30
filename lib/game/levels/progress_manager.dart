import 'package:shared_preferences/shared_preferences.dart';

class SaveManager {
  static const String _unlockedKey = 'skipper_unlocked_level';
  static const String _completedPrefix = 'skipper_level_';
  static const String _bestTimePrefix = 'skipper_level_';
  static const String _bestSeedPrefix = 'skipper_level_seed_';

  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_unlockedKey) ?? 1;
  }

  static Future<void> setUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_unlockedKey) ?? 1;
    if (level > current) {
      await prefs.setInt(_unlockedKey, level);
    }
  }

  static Future<bool> isLevelCompleted(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_completedPrefix${level}_completed') ?? false;
  }

  static Future<void> setLevelCompleted(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_completedPrefix${level}_completed', true);
  }

  static Future<String?> getBestTime(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_bestTimePrefix${level}_best_time');
  }

  static Future<void> setBestTime(int level, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_bestTimePrefix${level}_best_time';
    final current = prefs.getString(key);
    if (current == null || time.compareTo(current) < 0) {
      await prefs.setString(key, time);
    }
  }

  static Future<int?> getBestSeed(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_bestSeedPrefix$level');
  }

  static Future<void> setBestSeed(int level, int seed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_bestSeedPrefix$level', seed);
  }
}

class ProgressManager {
  final int totalLevels;

  ProgressManager(this.totalLevels);

  Future<int> getUnlockedLevel() => SaveManager.getUnlockedLevel();

  Future<bool> isUnlocked(int level) async {
    final unlocked = await SaveManager.getUnlockedLevel();
    return level <= unlocked;
  }

  Future<bool> isCompleted(int level) => SaveManager.isLevelCompleted(level);

  Future<void> completeLevel(int level, Duration time, int seed) async {
    await SaveManager.setLevelCompleted(level);
    final minutes = time.inMinutes.toString().padLeft(2, '0');
    final seconds = (time.inSeconds % 60).toString().padLeft(2, '0');
    await SaveManager.setBestTime(level, '$minutes:$seconds');
    await SaveManager.setBestSeed(level, seed);
    final nextLevel = level + 1;
    await SaveManager.setUnlockedLevel(nextLevel > totalLevels ? totalLevels : nextLevel);
  }

  Future<String?> getBestTime(int level) => SaveManager.getBestTime(level);
}
