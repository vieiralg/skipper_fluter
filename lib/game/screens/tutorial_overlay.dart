import 'package:flutter/material.dart';
import '../skipper_game.dart';
import '../../theme/text_styles.dart';
import '../config/palette.dart';

class TutorialOverlay extends StatefulWidget {
  final SkipperGame game;
  const TutorialOverlay({super.key, required this.game});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.game.overlays.remove('tutorial');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.game.overlays.remove('tutorial'),
      child: Container(
        color: const Color(0xBF000000),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BEM-VINDO AO SKIPPER!',
                style: AppTextStyles.pixelFont(20, Palette.starColor),
              ),
              const SizedBox(height: 24),
              Text(
                'COLETE AS ESTRELAS NA ORDEM CORRETA',
                style: AppTextStyles.pixelFont(16, Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                ' 2  →  4  →  6  →  8  →  10 ',
                style: AppTextStyles.pixelFont(22, Palette.starColor),
              ),
              const SizedBox(height: 24),
              Text(
                'Use os botões para pular e andar',
                style: AppTextStyles.pixelFont(13, Palette.pendingText),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _pulseController,
                child: Text(
                  '(toque na tela para começar)',
                  style: AppTextStyles.pixelFont(11, Palette.timerColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
