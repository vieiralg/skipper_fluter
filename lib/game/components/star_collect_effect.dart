import 'dart:ui';

import 'package:flame/components.dart';

class StarCollectEffect extends PositionComponent {
  double _elapsed = 0;

  StarCollectEffect({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(48),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= 0.35) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_elapsed / 0.35).clamp(0.0, 1.0);
    final alpha = ((1 - t) * 220).round();
    final radius = 8 + 22 * t;
    final center = Offset(width / 2, height / 2);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * (1 - t)
      ..color = Color.fromARGB(alpha, 255, 236, 92);

    final glow = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromARGB((alpha * 0.35).round(), 255, 255, 210);

    canvas.drawCircle(center, radius * 0.45, glow);
    canvas.drawCircle(center, radius, ring);
  }
}
