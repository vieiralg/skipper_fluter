import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart';
import 'config/game_config.dart' as config;
import 'components/background_cache.dart';
import 'components/platform.dart';
import 'components/player.dart';
import 'components/star.dart';
import 'components/star_collect_effect.dart';
import 'ui/hud.dart';
import 'ui/touch_controls.dart';
import 'ui/keyboard_input.dart';
import 'game_state.dart';
import 'levels/generated_level.dart';
import 'levels/platform_spawner.dart';
import 'levels/difficulty_manager.dart';
import 'levels/progress_manager.dart';
import 'levels/star_spawner.dart';

class SkipperGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents<World> {
  final GeneratedLevel levelData;
  late final GameState state;
  late final PlayerComponent player;
  late final TouchControlsComponent touchControls;
  late final HUDComponent hud;
  Sprite? heartFullSprite;
  Sprite? heartEmptySprite;
  bool _timerRunning = false;
  bool _keyboardLeft = false;
  bool _keyboardRight = false;
  bool _keyboardJump = false;
  bool _touchLeft = false;
  bool _touchRight = false;
  bool _touchJump = false;
  bool _progressSaved = false;
  bool _endAudioPlayed = false;
  final Random _random = Random();
  late List<PlatformComponent> _platforms;
  late List<StarComponent> _stars;

  SkipperGame({required this.levelData})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: config.virtualWidth,
            height: config.virtualHeight,
            viewfinder: Viewfinder()..anchor = Anchor.topLeft,
          ),
        );

  @override
  Future<void> onLoad() async {
    state = GameState(levelData: levelData);

    heartFullSprite = await Sprite.load('hud/heart_full.png');
    heartEmptySprite = await Sprite.load('hud/heart_empty.png');

    world.add(BackgroundComponent());

    final platformSpawner = PlatformSpawner(world);
    _platforms = platformSpawner.spawn(levelData.platforms);

    final starSpawner = StarSpawner(world);
    _stars = starSpawner.spawn(levelData.stars, _platforms);

    player = PlayerComponent(
      position: Vector2(36, config.groundY - config.playerHeight),
    );
    world.add(player);

    hud = HUDComponent();
    camera.viewport.add(hud);

    touchControls = TouchControlsComponent();
    camera.viewport.add(touchControls);

    add(KeyboardInputComponent());

    state.addListener(_onStateChanged);

    await AudioManager.init();
    AudioManager.playBgm();

    _checkTutorial();
  }

  @override
  void onRemove() {
    state.removeListener(_onStateChanged);
    super.onRemove();
  }

  void handlePointerDown(int pointerId, Offset localPosition) {
    final pos = camera.viewport.globalToLocal(Vector2(localPosition.dx, localPosition.dy));
    touchControls.handleVirtualDown(pointerId, pos);
  }

  void handlePointerUp(int pointerId, Offset localPosition) {
    final pos = camera.viewport.globalToLocal(Vector2(localPosition.dx, localPosition.dy));
    touchControls.handleVirtualUp(pointerId, pos);
  }

  void handlePointerCancel(int pointerId) {
    touchControls.handleVirtualCancel(pointerId);
  }

  void setKeyboardInput({
    required bool left,
    required bool right,
    required bool jump,
  }) {
    _keyboardLeft = left;
    _keyboardRight = right;
    _keyboardJump = jump;
  }

  void setTouchInput({
    required bool left,
    required bool right,
    required bool jump,
  }) {
    _touchLeft = left;
    _touchRight = right;
    _touchJump = jump;
  }

  void spawnStarCollectEffect(Vector2 position) {
    world.add(StarCollectEffect(position: position));
  }

  void _applyPlayerInput() {
    final left = _keyboardLeft || _touchLeft;
    final right = _keyboardRight || _touchRight;
    player.setMoveLeft(left && !right);
    player.setMoveRight(right && !left);
    player.setJumpHeld(_keyboardJump || _touchJump);
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenTutorial') ?? false;
    if (!hasSeen) {
      state.hasSeenTutorial = true;
      overlays.add('tutorial');
      await prefs.setBool('hasSeenTutorial', true);
    }
  }

  void _onStateChanged() {
    if (state.isVictory) {
      _timerRunning = false;
      _playEndAudioOnce(victory: true);
      _saveProgressOnce();
      overlays.add('victory');
    } else if (state.isGameOver) {
      _timerRunning = false;
      _playEndAudioOnce(victory: false);
      overlays.add('gameOver');
    }
    if (!state.isPaused) {
      overlays.remove('pause');
    }
  }

  void togglePause() {
    if (state.isVictory || state.isGameOver) return;
    state.setPaused(!state.isPaused);
    if (state.isPaused) {
      _timerRunning = false;
      AudioManager.muffleBgm();
      overlays.add('pause');
    } else {
      _timerRunning = true;
      AudioManager.restoreBgm();
      overlays.remove('pause');
    }
  }

  Future<void> leaveLevel() async {
    _timerRunning = false;
    await AudioManager.fadeOutBgm();
  }

  void restart() {
    overlays.remove('victory');
    overlays.remove('gameOver');
    overlays.remove('tutorial');
    overlays.remove('pause');
    state.reset();
    _progressSaved = false;
    _endAudioPlayed = false;
    _timerRunning = false;
    AudioManager.playBgm();
    AudioManager.restoreBgm();

    for (final platform in _platforms) {
      final pos = levelData.platforms.firstWhere((p) => p.id == platform.index);
      platform.setBasePosition(pos.position.clone());
      platform.bobPhase = _random.nextDouble() * pi * 2;
    }

    player.position.setValues(36, config.groundY - config.playerHeight);
    player.vy = 0;
    player.vx = 0;
    player.isGrounded = true;
    player.isHoldingJump = false;
    setKeyboardInput(left: false, right: false, jump: false);
    setTouchInput(left: false, right: false, jump: false);

    for (final star in _stars) {
      star.isCollected = false;
      star.bobPhase = _random.nextDouble() * pi * 2;
      final starData = levelData.stars[star.starIndex];
      final platform = _platforms.firstWhere(
        (p) => p.index == starData.platformId,
        orElse: () => _platforms.first,
      );
      star.setBasePosition(Vector2(
        platform.position.x + starData.offsetX,
        platform.position.y - config.starSize / 2,
      ));
    }
  }

  void _playEndAudioOnce({required bool victory}) {
    if (_endAudioPlayed) return;
    _endAudioPlayed = true;
    AudioManager.fadeOutBgm();
    if (victory) {
      AudioManager.playLevelComplete();
    } else {
      AudioManager.playGameOver();
    }
  }

  Future<void> _saveProgressOnce() async {
    if (_progressSaved) return;
    _progressSaved = true;
    final progress = ProgressManager(DifficultyManager.builtInLevels.length);
    await progress.completeLevel(levelData.levelNumber, state.elapsedTime, levelData.seed);
  }

  @override
  void update(double dt) {
    _applyPlayerInput();
    if (state.isPaused || state.isVictory || state.isGameOver) {
      super.update(dt);
      return;
    }
    if (!_timerRunning) {
      _timerRunning = true;
    }
    if (_timerRunning) {
      state.elapsedTime += Duration(milliseconds: (dt * 1000).round());
    }
    super.update(dt);
  }

}
