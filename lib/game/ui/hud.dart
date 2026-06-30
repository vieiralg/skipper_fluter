import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/palette.dart';
import '../config/game_config.dart' as config;
import '../skipper_game.dart';

class HUDComponent extends Component {
  late final TextComponent _progressText;
  final List<SpriteComponent> _hearts = [];

  @override
  Future<void> onLoad() async {
    final heartFull = await Sprite.load('hud/heart_full.png');
    final pauseSprite = await Sprite.load('hud/pause_icon.png');

    for (var i = 0; i < config.maxHP; i++) {
      final heart = SpriteComponent(
        sprite: heartFull,
        size: Vector2(config.heartSize, config.heartSize),
        position: Vector2(16 + i * 28, 3),
      );
      _hearts.add(heart);
      add(heart);
    }

    final pauseBtn = SpriteComponent(
      sprite: pauseSprite,
      size: Vector2(config.pauseButtonSize, config.pauseButtonSize),
      position: Vector2(764, 3),
    );
    add(pauseBtn);

    _progressText = TextComponent(
      position: Vector2(config.virtualWidth / 2, 7),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'PressStart2P',
          color: Palette.pendingText,
        ),
      ),
      anchor: Anchor.topCenter,
    );
    add(_progressText);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, config.virtualWidth, config.hudHeight),
      Paint()..color = Palette.hudBg,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, config.hudHeight - 2, config.virtualWidth, 2),
      Paint()..color = Palette.hudBorder,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    final game = findGame() as SkipperGame?;
    if (game == null) return;
    final state = game.state;

    for (var i = 0; i < _hearts.length; i++) {
      final isFlashingHeart = i == state.currentHP && game.player.isInvincible;
      if (isFlashingHeart) {
        final phase = (game.player.damageTimer / 0.12).floor() % 2;
        _hearts[i].sprite = phase == 0 ? game.heartFullSprite : game.heartEmptySprite;
      } else {
        _hearts[i].sprite = i < state.currentHP ? game.heartFullSprite : game.heartEmptySprite;
      }
    }

    final sequence = state.correctSequence;
    final buffer = StringBuffer();
    for (var i = 0; i < sequence.length; i++) {
      final num = sequence[i];
      final collected = i < state.collectedIndex;
      if (collected) {
        buffer.write('[');
        buffer.write(num);
        buffer.write(']');
      } else {
        buffer.write(' ');
        buffer.write(num);
        buffer.write(' ');
      }
      if (i < sequence.length - 1) {
        buffer.write(' - ');
      }
    }
    _progressText.text = buffer.toString();

    _progressText.position.x = config.virtualWidth / 2;
  }
}
