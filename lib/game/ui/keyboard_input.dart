import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../skipper_game.dart';

class KeyboardInputComponent extends Component with KeyboardHandler {
  final Set<LogicalKeyboardKey> _lastKeys = {};

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _lastKeys
      ..clear()
      ..addAll(keysPressed);
    final game = findGame() as SkipperGame?;
    if (game == null) return false;

    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.keyP) {
      if (event is KeyDownEvent) {
        game.togglePause();
      }
      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyE ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      if (event is KeyDownEvent) {
        game.player.interact();
      }
      return true;
    }

    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final game = findGame() as SkipperGame?;
    if (game == null) return;

    game.setKeyboardInput(
      left: _lastKeys.contains(LogicalKeyboardKey.arrowLeft) ||
          _lastKeys.contains(LogicalKeyboardKey.keyA),
      right: _lastKeys.contains(LogicalKeyboardKey.arrowRight) ||
          _lastKeys.contains(LogicalKeyboardKey.keyD),
      jump: _lastKeys.contains(LogicalKeyboardKey.space) ||
          _lastKeys.contains(LogicalKeyboardKey.arrowUp) ||
          _lastKeys.contains(LogicalKeyboardKey.keyW),
    );
  }
}
