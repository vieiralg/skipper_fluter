import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../skipper_game.dart';
import '../../theme/text_styles.dart';
import '../config/palette.dart';
import '../levels/difficulty_manager.dart';
import '../levels/level_generator.dart';
import '../ui/pixel_menu.dart';
import 'game_screen.dart';

class VictoryOverlay extends StatelessWidget {
  final SkipperGame game;
  final int levelNumber;
  const VictoryOverlay(
      {super.key, required this.game, required this.levelNumber});

  @override
  Widget build(BuildContext context) {
    final state = game.state;
    final sequence = state.correctSequence;
    final levels = DifficultyManager.builtInLevels;
    final nextIndex =
        levels.indexWhere((level) => level.levelNumber == levelNumber + 1);
    final hasNextLevel = nextIndex != -1;
    final mediaSize = MediaQuery.sizeOf(context);
    final isCompactMobile = !kIsWeb && mediaSize.shortestSide < 600;
    final panelWidth = isCompactMobile ? 320.0 : 360.0;
    final panelPadding =
        isCompactMobile ? const EdgeInsets.all(18) : const EdgeInsets.all(26);
    final titleSize = isCompactMobile ? 28.0 : 34.0;
    final textSize = isCompactMobile ? 9.0 : 11.0;
    final sequenceTextSize = isCompactMobile ? 12.0 : 14.0;
    final buttonHeight = isCompactMobile ? 42.0 : 50.0;
    final buttonTextSize = isCompactMobile ? 13.0 : 16.0;
    final smallGap = isCompactMobile ? 8.0 : 10.0;
    final mediumGap = isCompactMobile ? 10.0 : 16.0;
    final largeGap = isCompactMobile ? 12.0 : 22.0;

    return Container(
      color: const Color(0xCC102A3A),
      child: Center(
        child: PixelPanel(
          width: panelWidth,
          padding: panelPadding,
          children: [
            PixelMenuTitle(text: 'VITÓRIA!', size: titleSize),
            SizedBox(height: isCompactMobile ? 8 : 12),
            PixelMenuText(
                text: 'VOCÊ COLETOU TODAS AS ESTRELAS!', size: textSize),
            SizedBox(height: mediumGap),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompactMobile ? 10 : 12,
                vertical: isCompactMobile ? 8 : 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF102631),
                border: Border.all(color: const Color(0xFFE8D189), width: 2),
              ),
              child: Text(
                sequence.join('  -  '),
                textAlign: TextAlign.center,
                style: AppTextStyles.pixelFont(sequenceTextSize, Colors.white),
              ),
            ),
            if (!hasNextLevel) ...[
              SizedBox(height: isCompactMobile ? 8 : 12),
              Text(
                'TODOS OS NÍVEIS DISPONÍVEIS FORAM CONCLUÍDOS.',
                textAlign: TextAlign.center,
                style: AppTextStyles.pixelFont(9, Colors.white),
              ),
            ],
            SizedBox(height: largeGap),
            if (hasNextLevel) ...[
              PixelMenuButton(
                label: 'PRÓXIMO NÍVEL',
                color: Palette.feedbackCorrect,
                height: buttonHeight,
                fontSize: buttonTextSize,
                onTap: () {
                  final seed = DateTime.now().millisecondsSinceEpoch;
                  final generator =
                      LevelGenerator(definition: levels[nextIndex], seed: seed);
                  final levelData = generator.generate();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => GameScreen(levelData: levelData),
                    ),
                  );
                },
              ),
              SizedBox(height: smallGap),
            ],
            PixelMenuButton(
              label: 'SELEÇÃO DE NÍVEIS',
              color: Palette.platformBody,
              height: buttonHeight,
              fontSize: buttonTextSize,
              onTap: () => Navigator.of(context).pop(),
            ),
            SizedBox(height: smallGap),
            PixelMenuButton(
              label: 'REJOGAR',
              color: Palette.feedbackCorrect,
              height: buttonHeight,
              fontSize: buttonTextSize,
              onTap: () => game.restart(),
            ),
            SizedBox(height: smallGap),
            PixelMenuButton(
              label: 'SAIR',
              color: Colors.white,
              danger: true,
              height: buttonHeight,
              fontSize: buttonTextSize,
              onTap: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
