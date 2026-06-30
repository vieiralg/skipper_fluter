import 'layout_archetype.dart';
import 'platform_data.dart';
import 'star_data.dart';

class GeneratedLevel {
  final int levelNumber;
  final String title;
  final int seed;
  final LayoutArchetype archetype;
  final List<PlatformData> platforms;
  final List<StarData> stars;
  final List<int> correctSequence;

  const GeneratedLevel({
    required this.levelNumber,
    required this.title,
    required this.seed,
    required this.archetype,
    required this.platforms,
    required this.stars,
    required this.correctSequence,
  });
}
