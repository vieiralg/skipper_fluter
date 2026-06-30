import 'dart:math';
import 'package:flame/components.dart';
import 'star_data.dart';
import '../config/game_config.dart' as config;
import '../components/star.dart';
import '../components/platform.dart';

class StarSpawner {
  final World world;

  StarSpawner(this.world);

  List<StarComponent> spawn(List<StarData> stars, List<PlatformComponent> platforms) {
    final components = <StarComponent>[];
    final random = Random();

    for (var i = 0; i < stars.length; i++) {
      final starData = stars[i];
      final platform = platforms.firstWhere(
        (p) => p.index == starData.platformId,
        orElse: () => platforms.first,
      );

      final posX = platform.position.x + starData.offsetX;
      final posY = platform.position.y - config.starSize / 2;

      final component = StarComponent(
        number: starData.value,
        starIndex: i,
        position: Vector2(posX, posY),
        isCorrect: starData.isCorrect,
        bobPhase: random.nextDouble() * pi * 2,
      );
      world.add(component);
      components.add(component);
    }

    return components;
  }
}
