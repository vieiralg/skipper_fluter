import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';
import '../config/palette.dart';
import '../levels/level_definition.dart';
import '../levels/difficulty_manager.dart';
import '../levels/level_generator.dart';
import '../levels/progress_manager.dart';
import '../ui/pixel_menu.dart';
import 'game_screen.dart';

const bool debugFixedSeed = false;

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final ProgressManager _progress = ProgressManager(DifficultyManager.builtInLevels.length);
  int _unlocked = 1;
  final Map<int, bool> _completed = {};
  final Map<int, String?> _bestTimes = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _unlocked = await _progress.getUnlockedLevel();
    for (final level in DifficultyManager.builtInLevels) {
      _completed[level.levelNumber] = await _progress.isCompleted(level.levelNumber);
      _bestTimes[level.levelNumber] = await _progress.getBestTime(level.levelNumber);
    }
    setState(() => _loaded = true);
  }

  void _startLevel(LevelDefinition definition) {
    try {
      final seed = debugFixedSeed ? 0 : DateTime.now().millisecondsSinceEpoch;
      final generator = LevelGenerator(definition: definition, seed: seed);
      final levelData = generator.generate();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameScreen(levelData: levelData),
        ),
      ).then((_) => _loadProgress());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao iniciar o nível ${definition.levelNumber}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final levels = DifficultyManager.builtInLevels;

    return Scaffold(
      body: PixelMenuBackdrop(
        child: SafeArea(
          child: PixelPanel(
            width: 620,
            padding: const EdgeInsets.all(24),
            children: [
                    const PixelMenuTitle(text: 'SELECIONAR NÍVEL', size: 26),
                    const SizedBox(height: 8),
                    const PixelMenuText(text: 'ESCOLHA UMA FASE PARA JOGAR'),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final level in levels)
                          _LevelCard(
                            level: level,
                            isUnlocked: level.levelNumber <= _unlocked,
                            isCompleted: _completed[level.levelNumber] ?? false,
                            bestTime: _bestTimes[level.levelNumber],
                            onTap: level.levelNumber <= _unlocked ? () => _startLevel(level) : null,
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    PixelMenuButton(
                      label: 'VOLTAR',
                      color: Colors.white,
                      width: 220,
                      height: 46,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
          ),
        ),
        ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelDefinition level;
  final bool isUnlocked;
  final bool isCompleted;
  final String? bestTime;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    this.bestTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isUnlocked ? 1.0 : 0.55;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 250,
          height: 116,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isUnlocked ? const Color(0xFF2C5D70) : const Color(0xFF263846),
            border: Border.all(
              color: isCompleted
                  ? Palette.feedbackCorrect
                  : isUnlocked
                      ? const Color(0xFFE8D189)
                      : const Color(0xFF7892A0),
              width: 2,
            ),
            boxShadow: const [BoxShadow(offset: Offset(0, 4), blurRadius: 0, color: Color(0xFF102631))],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    isCompleted ? '★' : (isUnlocked ? '☆' : '🔒'),
                    style: AppTextStyles.pixelFont(
                      18,
                      isCompleted ? Palette.starColor : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NÍVEL ${level.levelNumber.toString().padLeft(2, '0')}',
                      style: AppTextStyles.pixelFont(15, Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                level.title,
                style: AppTextStyles.pixelFont(11, const Color(0xFFE8D189)),
              ),
              if (bestTime != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Melhor: $bestTime',
                  style: AppTextStyles.pixelFont(10, Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
