import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../audio_manager.dart';
import '../config/palette.dart';
import '../ui/pixel_menu.dart';
import 'level_select_screen.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
          PixelMenuBackdrop(
            child: PixelPanel(
              children: [
                const PixelMenuTitle(text: 'SKIPPER', color: Colors.white, size: 48),
                const SizedBox(height: 8),
                const PixelMenuText(text: 'PULE E CONTE', size: 14),
                  const SizedBox(height: 32),
                  PixelMenuButton(
                    label: 'JOGAR',
                    color: Palette.feedbackCorrect,
                    onTap: () async {
                      await AudioManager.init();
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LevelSelectScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  PixelMenuButton(
                    label: 'SAIR',
                    color: Palette.platformBody,
                    danger: true,
                    onTap: () {
                      SystemNavigator.pop();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
