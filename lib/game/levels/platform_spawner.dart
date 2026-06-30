import 'package:flame/components.dart';
import 'platform_data.dart';
import '../components/platform.dart';

class PlatformSpawner {
  final World world;

  PlatformSpawner(this.world);

  List<PlatformComponent> spawn(List<PlatformData> platforms) {
    final components = <PlatformComponent>[];
    for (final data in platforms) {
      final component = PlatformComponent(
        index: data.id,
        position: data.position.clone(),
        width: data.width,
        bobPhase: data.id * 1.7,
      );
      world.add(component);
      components.add(component);
    }
    return components;
  }
}
