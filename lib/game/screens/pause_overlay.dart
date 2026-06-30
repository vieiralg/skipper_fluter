import 'package:flutter/material.dart';
import '../skipper_game.dart';
import '../config/palette.dart';
import '../ui/pixel_menu.dart';

class PauseOverlay extends StatelessWidget {
  final SkipperGame game;
  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xC0102430),
      child: Center(
        child: PixelPanel(
          width: 330,
          children: [
            const PixelMenuTitle(text: 'PAUSADO', color: Colors.white, size: 30),
            const SizedBox(height: 26),
            PixelMenuButton(
              label: 'CONTINUAR',
              color: Palette.feedbackCorrect,
              onTap: () => game.togglePause(),
            ),
            const SizedBox(height: 12),
            PixelMenuButton(
              label: 'RECOMEÇAR',
              color: Palette.starColor,
              onTap: () => game.restart(),
            ),
            const SizedBox(height: 12),
            PixelMenuButton(
              label: 'SELEÇÃO DE NÍVEIS',
              color: Palette.platformBody,
              onTap: () async {
                await game.leaveLevel();
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
            PixelMenuButton(
              label: 'SAIR',
              color: Colors.white,
              danger: true,
              onTap: () async {
                await game.leaveLevel();
                if (!context.mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
