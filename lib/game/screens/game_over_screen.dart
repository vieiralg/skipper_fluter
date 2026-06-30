import 'package:flutter/material.dart';
import '../skipper_game.dart';
import '../config/palette.dart';
import '../ui/pixel_menu.dart';

class GameOverOverlay extends StatelessWidget {
  final SkipperGame game;
  final int levelNumber;
  const GameOverOverlay({super.key, required this.game, required this.levelNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xCC2A1015),
      child: Center(
        child: PixelPanel(
          width: 360,
          children: [
            const PixelMenuTitle(text: 'FIM DE JOGO', color: Palette.feedbackWrong, size: 30),
            const SizedBox(height: 16),
            const PixelMenuText(text: 'VOCÊ PERDEU TODOS OS CORAÇÕES'),
            const SizedBox(height: 28),
            PixelMenuButton(
              label: 'TENTAR NOVAMENTE',
              color: Palette.feedbackCorrect,
              onTap: () => game.restart(),
            ),
            const SizedBox(height: 12),
            PixelMenuButton(
              label: 'SELEÇÃO DE NÍVEIS',
              color: Palette.platformBody,
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 12),
            PixelMenuButton(
              label: 'SAIR',
              color: Colors.white,
              danger: true,
              onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
