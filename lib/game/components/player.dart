import 'dart:ui' show Canvas;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../audio_manager.dart';
import '../config/game_config.dart' as config;
import '../game_state.dart';
import '../skipper_game.dart';
import 'platform.dart';
import 'star.dart';

class PlayerComponent extends PositionComponent {
  double vy = 0;
  double vx = 0;
  bool isGrounded = false;
  bool isHoldingJump = false;
  double _coyoteTimer = 0;
  double _previousBottom = 0;
  double _damageTimer = 0;
  bool _isInvincible = false;
  bool _moveLeftHeld = false;
  bool _moveRightHeld = false;
  bool _jumpHeld = false;
  SkipperGame? _game;

  SpriteAnimation? _idleAnimation;
  SpriteAnimation? _jumpAnimation;
  SpriteAnimation? _walkAnimation;
  PositionComponent? _sprite;
  int _lastDir = 1;
  String _currentAnim = '';

  PlayerComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2(config.playerWidth, config.playerHeight),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    _game = findGame() as SkipperGame?;

    _idleAnimation = await SpriteAnimation.load(
      'player/idle.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.18,
        textureSize: Vector2(52, 90),
        amountPerRow: 4,
      ),
    );
    _jumpAnimation = await SpriteAnimation.load(
      'player/jump.png',
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.09,
        textureSize: Vector2(62, 123),
        amountPerRow: 5,
        loop: false,
      ),
    );
    _walkAnimation = await SpriteAnimation.load(
      'player/walk.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.08,
        textureSize: Vector2(61, 92),
        amountPerRow: 6,
      ),
    );

    _showIdle();

    add(RectangleHitbox(
      size: Vector2(config.playerHitboxW, config.playerHitboxH),
      position: Vector2(config.playerHitboxX, config.playerHitboxY),
    ));
  }

  void _showIdle() {
    if (_currentAnim == 'idle') return;
    _sprite?.removeFromParent();
    _sprite = SpriteAnimationComponent(animation: _idleAnimation, size: size);
    _sprite!.anchor = Anchor.center;
    _sprite!.position = size / 2;
    add(_sprite!);
    _currentAnim = 'idle';
  }

  void _showWalk() {
    if (_currentAnim == 'walk') return;
    _sprite?.removeFromParent();
    _sprite = SpriteAnimationComponent(animation: _walkAnimation, size: size);
    _sprite!.anchor = Anchor.center;
    _sprite!.position = size / 2;
    add(_sprite!);
    _currentAnim = 'walk';
  }

  void _showJump() {
    if (_currentAnim == 'jump') return;
    _sprite?.removeFromParent();
    _sprite = SpriteAnimationComponent(animation: _jumpAnimation, size: size);
    _sprite!.anchor = Anchor.center;
    _sprite!.position = size / 2;
    add(_sprite!);
    _currentAnim = 'jump';
  }

  void _updateSprite() {
    if (vx.abs() > 1) {
      _lastDir = vx > 0 ? 1 : -1;
    }

    if (!isGrounded || vy < 0) {
      _showJump();
    } else if (vx.abs() > 1) {
      _showWalk();
    } else {
      _showIdle();
    }

    if (_sprite != null) {
      _sprite!.scale.x = _lastDir > 0 ? 1 : -1;
    }
  }

  void setMoveLeft(bool held) {
    _moveLeftHeld = held;
    if (held) _moveRightHeld = false;
  }

  void setMoveRight(bool held) {
    _moveRightHeld = held;
    if (held) _moveLeftHeld = false;
  }

  void setJumpHeld(bool held) {
    final justPressed = held && !_jumpHeld;
    _jumpHeld = held;
    if (justPressed) {
      if (_game?.state == null) return;
      if (_game!.state.isPaused || _game!.state.isGameOver || _game!.state.isVictory) return;
      if (!(isGrounded || _coyoteTimer < config.coyoteTime)) return;
      vy = config.jumpVelocity;
      AudioManager.playJump();
      isGrounded = false;
      isHoldingJump = true;
      _coyoteTimer = 999;
    }
  }

  void interact() {
    final state = _game?.state;
    if (state == null) return;
    if (state.isPaused || state.isGameOver || state.isVictory) return;

    final stars = _game?.world.children.query<StarComponent>();
    if (stars == null) return;

    StarComponent? nearestStar;
    const double collectDist = 16;
    final playerCenter = absoluteCenter;

    for (final star in stars) {
      if (star.isCollected) continue;
      final dist = playerCenter.distanceTo(star.absoluteCenter);
      if (dist < collectDist) {
        nearestStar = star;
        break;
      }
    }

    if (nearestStar == null) return;

    final expectedNumber = state.correctSequence[state.collectedIndex];
    if (nearestStar.number == expectedNumber) {
      state.collectStar(nearestStar.number);
      AudioManager.playCollectCorrect();
      _game?.spawnStarCollectEffect(nearestStar.absoluteCenter);
      nearestStar.isCollected = true;
    } else {
      state.loseHP();
      AudioManager.playCollectWrong();
      _startDamageAnimation();
    }
  }

  void _startDamageAnimation() {
    _isInvincible = true;
    _damageTimer = 0;
  }

  bool get isInvincible => _isInvincible;
  double get damageTimer => _damageTimer;

  GameState? get state => _game?.state;

  @override
  void update(double dt) {
    super.update(dt);

    final state = _game?.state;
    if (state == null) return;
    if (state.isPaused || state.isVictory || state.isGameOver) return;

    _previousBottom = y + height;

    if (_moveLeftHeld) {
      vx = -config.moveSpeed;
    } else if (_moveRightHeld) {
      vx = config.moveSpeed;
    } else {
      vx = 0;
    }

    if (!isGrounded) _coyoteTimer += dt;

    if (!_jumpHeld && isHoldingJump && vy < 0) {
      vy *= config.jumpCutMultiplier;
      isHoldingJump = false;
    }
    if (!_jumpHeld) {
      isHoldingJump = false;
    }

    final grav = (isHoldingJump && !isGrounded) ? config.gravityHold : config.gravity;
    vy += grav * dt;
    vy = vy.clamp(-double.infinity, config.maxFallSpeed);

    x += vx * dt;
    y += vy * dt;

    isGrounded = false;
    _checkPlatformCollision();
    _checkGroundCollision();
    _clampToBounds();
    _checkFall(dt);
    _updateSprite();

    if (_isInvincible) {
      _damageTimer += dt;
      if (_damageTimer > 0.6) _isInvincible = false;
    }
  }

  void _checkPlatformCollision() {
    final platforms = _game?.world.children.query<PlatformComponent>();
    if (platforms == null) return;

    for (final platform in platforms) {
      if (vy > 0 &&
          y + height >= platform.y &&
          _previousBottom <= platform.y + 4 &&
          x + width > platform.x &&
          x < platform.x + platform.width) {
        y = platform.y - height;
        vy = 0;
        isGrounded = true;
        _coyoteTimer = 0;
        state?.lastPlatformIndex = platform.index;
      }
    }
  }

  void _checkGroundCollision() {
    if (y + height >= config.groundY) {
      y = config.groundY - height;
      vy = 0;
      isGrounded = true;
      _coyoteTimer = 0;
    }
  }

  void _clampToBounds() {
    x = x.clamp(2, config.virtualWidth - width - 2);
    if (y < config.hudHeight) {
      y = config.hudHeight;
      if (vy < 0) vy = 0;
    }
  }

  void _checkFall(double dt) {
    if (y > config.virtualHeight) {
      _game?.state.loseHP();
      _respawn();
      _startDamageAnimation();
    }
  }

  void _respawn() {
    final platforms = _game?.world.children.query<PlatformComponent>();
    if (platforms == null) return;
    final idx = state?.lastPlatformIndex ?? 0;
    final platform = platforms.where((p) => p.index == idx).firstOrNull;
    if (platform != null) {
      x = platform.x + (platform.width - width) / 2;
      y = platform.y - height;
    }
    vy = 0;
    isGrounded = true;
    _coyoteTimer = 0;
  }

  @override
  void render(Canvas canvas) {
    if (_isInvincible && _damageTimer % 0.2 < 0.1) return;
    super.render(canvas);
  }
}
