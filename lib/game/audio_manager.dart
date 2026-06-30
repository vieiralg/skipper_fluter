import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static const double sfxVolume = 0.75;
  static const double bgmVolume = 0.05;
  static const double muffledBgmVolume = 0.018;
  static bool _loaded = false;
  static bool _bgmPlaying = false;
  static double _currentBgmVolume = bgmVolume;

  static Future<void> init() async {
    if (_loaded) return;
    await FlameAudio.audioCache.loadAll([
      'sfx/collect_correct.mp3',
      'sfx/collect_wrong.mp3',
      'sfx/game_over.mp3',
      'sfx/jump.mp3',
      'sfx/level_complete.mp3',
    ]);
    _loaded = true;
  }

  static void playJump() {
    FlameAudio.play('sfx/jump.mp3', volume: sfxVolume);
  }

  static void playCollectCorrect() {
    FlameAudio.play('sfx/collect_correct.mp3', volume: sfxVolume);
  }

  static void playCollectWrong() {
    FlameAudio.play('sfx/collect_wrong.mp3', volume: sfxVolume);
  }

  static void playGameOver() {
    FlameAudio.play('sfx/game_over.mp3', volume: sfxVolume);
  }

  static void playLevelComplete() {
    FlameAudio.play('sfx/level_complete.mp3', volume: sfxVolume);
  }

  static void playBgm() {
    if (_bgmPlaying) return;
    _bgmPlaying = true;
    _currentBgmVolume = bgmVolume;
    FlameAudio.bgm.play('music/bgm.mp3', volume: bgmVolume);
  }

  static Future<void> muffleBgm() async {
    if (!_bgmPlaying) return;
    _currentBgmVolume = muffledBgmVolume;
    await FlameAudio.bgm.audioPlayer.setVolume(muffledBgmVolume);
  }

  static Future<void> restoreBgm() async {
    if (!_bgmPlaying) return;
    _currentBgmVolume = bgmVolume;
    await FlameAudio.bgm.audioPlayer.setVolume(bgmVolume);
  }

  static void stopBgm() {
    _bgmPlaying = false;
    FlameAudio.bgm.stop();
  }

  static Future<void> fadeOutBgm() async {
    if (!_bgmPlaying) return;
    _bgmPlaying = false;

    const steps = 12;
    final startVolume = _currentBgmVolume;
    for (var i = steps - 1; i >= 0; i--) {
      await FlameAudio.bgm.audioPlayer.setVolume(startVolume * i / steps);
      await Future<void>.delayed(const Duration(milliseconds: 45));
    }

    await FlameAudio.bgm.stop();
    _currentBgmVolume = bgmVolume;
    await FlameAudio.bgm.audioPlayer.setVolume(bgmVolume);
  }
}
