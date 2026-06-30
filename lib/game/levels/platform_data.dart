import 'package:flame/extensions.dart';

class PlatformData {
  final int id;
  final Vector2 position;
  final double width;
  final double height;
  final bool isSupportPlatform;

  const PlatformData({
    required this.id,
    required this.position,
    required this.width,
    this.height = 16,
    this.isSupportPlatform = false,
  });

  double get centerX => position.x + width / 2;
  double get centerY => position.y + height / 2;
  double get right => position.x + width;
  double get bottom => position.y + height;
}
