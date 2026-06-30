import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../skipper_game.dart';
import '../levels/generated_level.dart';
import 'pause_overlay.dart';
import 'victory_screen.dart';
import 'game_over_screen.dart';
import 'tutorial_overlay.dart';

class GameScreen extends StatefulWidget {
  final GeneratedLevel levelData;

  const GameScreen({super.key, required this.levelData});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SkipperGame _game;

  @override
  void initState() {
    super.initState();
    _game = SkipperGame(levelData: widget.levelData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) => _game.handlePointerDown(event.pointer, event.localPosition),
        onPointerUp: (event) => _game.handlePointerUp(event.pointer, event.localPosition),
        onPointerCancel: (event) => _game.handlePointerCancel(event.pointer),
        child: GameWidget(
          game: _game,
          overlayBuilderMap: {
            'pause': (ctx, game) => PauseOverlay(game: game as SkipperGame),
            'victory': (ctx, game) => VictoryOverlay(
              game: game as SkipperGame,
              levelNumber: widget.levelData.levelNumber,
            ),
            'gameOver': (ctx, game) => GameOverOverlay(
              game: game as SkipperGame,
              levelNumber: widget.levelData.levelNumber,
            ),
            'tutorial': (ctx, game) => TutorialOverlay(game: game as SkipperGame),
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _game.state.dispose();
    super.dispose();
  }
}
