import 'dart:math';
import 'package:flame/components.dart';
import '../config/game_config.dart' as config;

class PlatformComponent extends SpriteComponent {
  final int index;
  late Vector2 basePosition;
  late double bobPhase;

  PlatformComponent({
    required this.index,
    required Vector2 position,
    required double width,
    required this.bobPhase,
  }) : super(
          position: position,
          size: Vector2(width, config.platformHeight),
        ) {
    basePosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('objects/plataform.png');
  }

  void setBasePosition(Vector2 value) {
    basePosition = value.clone();
    position = value.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    bobPhase += dt * 1.25;
    y = basePosition.y + 3 * sin(bobPhase);
  }
}
