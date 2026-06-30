import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../config/game_config.dart' as config;
import 'player.dart';

class StarComponent extends PositionComponent with CollisionCallbacks {
  final int number;
  final int starIndex;
  final bool isCorrect;
  bool isCollected = false;
  bool isNearPlayer = false;
  Sprite? _sprite;
  late double bobPhase;
  Vector2 _basePosition;

  StarComponent({
    required this.number,
    required this.starIndex,
    required Vector2 position,
    required this.isCorrect,
    required this.bobPhase,
  }) : _basePosition = position.clone(),
       super(
          position: position,
          size: Vector2(config.starSize, config.starSize),
          anchor: Anchor.center,
        );

  void setBasePosition(Vector2 value) {
    _basePosition = value.clone();
    position = value.clone();
  }

  @override
  Future<void> onLoad() async {
    _sprite = await Sprite.load('objects/star.png');
    add(CircleHitbox(radius: config.starInteractionRadius));
  }

  @override
  void update(double dt) {
    super.update(dt);
    bobPhase += dt * 1.55;
    x = _basePosition.x;
    y = _basePosition.y + 4 * sin(bobPhase);
  }

  @override
  void render(Canvas canvas) {
    if (isCollected || _sprite == null) return;

    _sprite!.render(canvas, size: size);

    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'PixelFont',
          shadows: const [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Color(0x80000000))
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((width - textPainter.width) / 2, (height - textPainter.height) / 2),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is PlayerComponent) {
      isNearPlayer = true;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is PlayerComponent) {
      isNearPlayer = false;
    }
  }
}
