import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/game_config.dart' as config;
import '../skipper_game.dart';

class TouchControlsComponent extends PositionComponent {
  TouchControlsComponent()
      : super(size: Vector2(config.virtualWidth, config.virtualHeight));

  late final Sprite _leftSprite;
  late final Sprite _rightSprite;
  late final Sprite _jumpSprite;
  late final Sprite _interactSprite;
  int? _movePointerId;
  int? _jumpPointerId;
  int? _interactPointerId;
  bool _leftPressed = false;
  bool _rightPressed = false;
  bool _jumpPressed = false;
  bool _interactPressed = false;

  @override
  Future<void> onLoad() async {
    _leftSprite = await Sprite.load('hud/btn_arrow_left.png');
    _rightSprite = await Sprite.load('hud/btn_arrow_right.png');
    _jumpSprite = await Sprite.load('hud/btn_jump.png');
    _interactSprite = await Sprite.load('hud/btn_interact.png');
  }

  void _renderButton(
      Canvas canvas, Sprite sprite, Vector2 pos, Vector2 size, bool pressed) {
    if (pressed) {
      canvas.save();
      final cx = pos.x + size.x / 2;
      final cy = pos.y + size.y / 2;
      canvas.translate(cx, cy);
      canvas.scale(0.88);
      canvas.translate(-cx, -cy);
      sprite.render(canvas, position: pos, size: size);
      canvas.restore();
    } else {
      sprite.render(canvas, position: pos, size: size);
    }
  }

  @override
  void render(Canvas canvas) {
    _renderButton(
        canvas, _leftSprite, Vector2(16, 398), Vector2(30, 30), _leftPressed);
    _renderButton(
        canvas, _rightSprite, Vector2(54, 398), Vector2(30, 30), _rightPressed);
    _renderButton(
        canvas, _jumpSprite, Vector2(759, 396), Vector2(30, 30), _jumpPressed);
    _renderButton(canvas, _interactSprite, Vector2(719, 398), Vector2(30, 30),
        _interactPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final game = findGame() as SkipperGame?;
    if (game == null) return;

    game.setTouchInput(
      left: _leftPressed,
      right: _rightPressed,
      jump: _jumpPressed,
    );
  }

  void handleVirtualDown(int pointerId, Vector2 pos) {
    final game = findGame() as SkipperGame?;
    if (game == null) return;

    const pauseHitTop = kIsWeb ? 2.0 : 3.0;
    const pauseHitBottom = kIsWeb ? 50.0 : 23.0;
    const pauseHitLeft = kIsWeb ? 746.0 : 764.0;
    const pauseHitRight = kIsWeb ? 794.0 : 784.0;
    if (pos.x >= pauseHitLeft &&
        pos.x <= pauseHitRight &&
        pos.y >= pauseHitTop &&
        pos.y <= pauseHitBottom) {
      game.togglePause();
      return;
    }
    if (pos.x >= 16 && pos.x <= 46 && pos.y >= 398 && pos.y <= 428) {
      _leftPressed = true;
      _rightPressed = false;
      _movePointerId = pointerId;
      return;
    }
    if (pos.x >= 54 && pos.x <= 84 && pos.y >= 398 && pos.y <= 428) {
      _rightPressed = true;
      _leftPressed = false;
      _movePointerId = pointerId;
      return;
    }
    if (pos.x >= 759 && pos.x <= 789 && pos.y >= 396 && pos.y <= 426) {
      _jumpPressed = true;
      _jumpPointerId = pointerId;
      return;
    }
    if (pos.x >= 719 && pos.x <= 749 && pos.y >= 398 && pos.y <= 428) {
      _interactPressed = true;
      _interactPointerId = pointerId;
      game.player.interact();
      return;
    }
  }

  void handleVirtualUp(int pointerId, Vector2 pos) {
    final game = findGame() as SkipperGame?;
    if (game == null) return;

    if (_movePointerId == pointerId ||
        (pos.x >= 16 && pos.x <= 84 && pos.y >= 398 && pos.y <= 428)) {
      _leftPressed = false;
      _rightPressed = false;
      _movePointerId = null;
      return;
    }
    if (_jumpPointerId == pointerId) {
      _jumpPressed = false;
      _jumpPointerId = null;
    }
    if (_interactPointerId == pointerId) {
      _interactPressed = false;
      _interactPointerId = null;
    }
  }

  void handleVirtualCancel(int pointerId) {
    final game = findGame() as SkipperGame?;
    if (game == null) return;

    if (_movePointerId == pointerId) {
      _leftPressed = false;
      _rightPressed = false;
      _movePointerId = null;
    }
    if (_jumpPointerId == pointerId) {
      _jumpPressed = false;
      _jumpPointerId = null;
    }
    if (_interactPointerId == pointerId) {
      _interactPressed = false;
      _interactPointerId = null;
    }
  }
}
