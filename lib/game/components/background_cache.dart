import 'package:flame/components.dart';

class BackgroundComponent extends SpriteComponent {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('background.png');
    size = Vector2(800, 450);
    position = Vector2.zero();
  }
}
