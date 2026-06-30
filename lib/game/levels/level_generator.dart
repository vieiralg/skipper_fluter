import 'dart:math';
import 'package:flame/extensions.dart';

import 'difficulty_manager.dart';
import 'difficulty_rules.dart';
import 'generated_level.dart';
import 'layout_archetype.dart';
import 'level_definition.dart';
import 'platform_data.dart';
import 'star_data.dart';

class LevelGenerator {
  final LevelDefinition definition;
  final int? seed;
  late Random _rng;

  static const double spawnX = 36;
  static const double spawnY = 326;
  static const double playerWidth = 25;
  static const double playerHeight = 44;
  static const double groundY = 370;
  static const double safeLeft = 35;
  static const double safeRight = 770;
  static const double safeTop = 60;
  static const double safeBottom = 304;

  LevelGenerator({required this.definition, this.seed}) {
    _rng = Random(seed ?? DateTime.now().microsecondsSinceEpoch);
  }

  GeneratedLevel generate() {
    final rules = DifficultyManager.getRules(definition.difficulty);
    final correctSequence = generateCorrectSequence();
    final baseSeed = seed ?? 0;

    for (var attempt = 0; attempt < rules.maxAttempts; attempt++) {
      final attemptSeed = baseSeed + attempt;
      _rng = Random(attemptSeed);
      final archetype = chooseArchetype();
      final platforms = generateMainPath(archetype, rules);
      if (!validateMainPath(platforms, rules, archetype, attemptSeed)) {
        continue;
      }

      final stars = generateStars(platforms, correctSequence);
      if (stars.length != correctSequence.length || stars.isEmpty) {
        _logFailure(attemptSeed, archetype, 'stars length is zero');
        continue;
      }

      final supports = definition.levelNumber >= 3 ? generateSupportPlatforms(platforms) : <PlatformData>[];
      final allPlatforms = [...platforms, ...supports]..sort((a, b) => a.id.compareTo(b.id));

      if (!validateNoOverlap(allPlatforms)) {
        _logFailure(attemptSeed, archetype, 'overlap between platform 0 and 1');
        continue;
      }
      if (!validateInsideBounds(allPlatforms)) {
        _logFailure(attemptSeed, archetype, 'inside bounds');
        continue;
      }

      final distractors = generateDistractors(correctSequence, definition.distractorCount);
      final finalStars = _mergeDistractors(stars, distractors);

      final level = GeneratedLevel(
        levelNumber: definition.levelNumber,
        title: definition.title,
        seed: attemptSeed,
        archetype: archetype,
        platforms: allPlatforms,
        stars: finalStars,
        correctSequence: correctSequence,
      );

      return level;
    }

    if (definition.levelNumber == 1) {
      return _fallbackLevel1(correctSequence);
    }

    throw StateError('Falha ao gerar nível ${definition.levelNumber}: nenhuma seed válida passou nas validações.');
  }

  LayoutArchetype chooseArchetype() {
    if (definition.levelNumber == 2) return LayoutArchetype.mixed;

    final pool = switch (definition.difficulty) {
      Difficulty.tutorial => const [LayoutArchetype.stairUp, LayoutArchetype.peak, LayoutArchetype.mixed],
      Difficulty.easy => const [LayoutArchetype.stairUp, LayoutArchetype.peak, LayoutArchetype.mixed],
      Difficulty.easyPlus => const [LayoutArchetype.stairUp, LayoutArchetype.peak, LayoutArchetype.mixed],
      Difficulty.medium => const [LayoutArchetype.zigZag, LayoutArchetype.peak, LayoutArchetype.valley],
      Difficulty.mediumPlus => const [LayoutArchetype.zigZag, LayoutArchetype.peak, LayoutArchetype.valley, LayoutArchetype.mixed],
      Difficulty.hard => const [LayoutArchetype.peak, LayoutArchetype.valley, LayoutArchetype.mixed],
      Difficulty.hardPlus => const [LayoutArchetype.zigZag, LayoutArchetype.peak, LayoutArchetype.valley, LayoutArchetype.mixed],
      Difficulty.master => const [LayoutArchetype.mixed, LayoutArchetype.peak, LayoutArchetype.valley, LayoutArchetype.zigZag],
    };
    return pool[_rng.nextInt(pool.length)];
  }

  List<int> generateCorrectSequence() {
    final values = <int>[];
    var current = definition.startValue;
    while (current <= definition.endValue && values.length < definition.correctCount) {
      values.add(current);
      current += definition.skipStep;
    }
    return values;
  }

  List<PlatformData> generateMainPath(LayoutArchetype archetype, DifficultyRules rules) {
    if (definition.levelNumber == 1) {
      return _generateTutorialPath(archetype, rules);
    }

    if (definition.levelNumber <= 3) {
      return _generateSafeForwardPath(archetype, rules);
    }

    final platforms = <PlatformData>[];

    for (var index = 0; index < definition.platformCount; index++) {
      PlatformData platform;
      if (index == 0) {
        platform = _generateFirstPlatform(rules, archetype);
      } else {
        platform = generateByArchetype(archetype, index, platforms, rules);
      }

      platform = applyControlledJitter(platform, index, platforms, rules);
      platforms.add(platform);
    }

    return platforms;
  }

  List<PlatformData> _generateSafeForwardPath(LayoutArchetype archetype, DifficultyRules rules) {
    if (definition.levelNumber == 2) {
      return _generateLevel2Path(rules);
    }

    final platforms = <PlatformData>[];
    final width = rules.minPlatformWidth;
    final startX = 85.0 + _range(-12, 12);
    final stepX = ((safeRight - width - startX) / max(1, definition.platformCount - 1)).clamp(58.0, 86.0);
    final yPattern = switch (archetype) {
      LayoutArchetype.peak => [292.0, 260.0, 228.0, 196.0, 228.0, 260.0],
      LayoutArchetype.mixed => [292.0, 252.0, 212.0, 252.0, 292.0, 242.0],
      _ => [292.0, 260.0, 228.0, 196.0, 164.0, 132.0, 104.0, 88.0, 76.0, 68.0],
    };

    for (var i = 0; i < definition.platformCount; i++) {
      platforms.add(PlatformData(
        id: i,
        position: Vector2(
          (startX + stepX * i + _range(-14, 14)).clamp(safeLeft, safeRight - width),
          (yPattern[i % yPattern.length] + _range(-8, 8)).clamp(safeTop, safeBottom),
        ),
        width: width,
      ));
    }

    return platforms;
  }

  List<PlatformData> _generateLevel2Path(DifficultyRules rules) {
    final base = const [
      (78.0, 300.0),
      (170.0, 270.0),
      (265.0, 228.0),
      (375.0, 260.0),
      (495.0, 225.0),
      (615.0, 280.0),
      (710.0, 235.0),
      (620.0, 178.0),
      (480.0, 150.0),
      (350.0, 178.0),
    ];
    final width = rules.minPlatformWidth;

    return [
      for (var i = 0; i < definition.platformCount && i < base.length; i++)
        PlatformData(
          id: i,
          position: Vector2(
            (base[i].$1 + _range(-6, 6)).clamp(safeLeft, safeRight - width),
            (base[i].$2 + _range(-6, 6)).clamp(safeTop, safeBottom),
          ),
          width: width,
        ),
    ];
  }

  List<PlatformData> _generateTutorialPath(LayoutArchetype archetype, DifficultyRules rules) {
    final base = switch (archetype) {
      LayoutArchetype.peak => const [
          (95.0, 298.0),
          (225.0, 258.0),
          (360.0, 214.0),
          (500.0, 254.0),
          (640.0, 210.0),
        ],
      LayoutArchetype.mixed => const [
          (92.0, 300.0),
          (230.0, 260.0),
          (370.0, 224.0),
          (520.0, 270.0),
          (650.0, 220.0),
        ],
      _ => const [
          (92.0, 300.0),
          (220.0, 266.0),
          (350.0, 232.0),
          (495.0, 198.0),
          (635.0, 164.0),
        ],
    };

    return [
      for (var i = 0; i < definition.platformCount && i < base.length; i++)
        PlatformData(
          id: i,
          position: Vector2(
            (base[i].$1 + _range(-20, 20)).clamp(safeLeft, safeRight - rules.maxPlatformWidth),
            (base[i].$2 + _range(-10, 10)).clamp(safeTop, safeBottom),
          ),
          width: rules.minPlatformWidth,
        ),
    ];
  }

  PlatformData _generateFirstPlatform(DifficultyRules rules, LayoutArchetype archetype) {
    final width = _randomWidth(rules);
    final y = definition.difficulty == Difficulty.tutorial ? _range(285.0, 300.0) : 292.0;
    final x = definition.difficulty == Difficulty.tutorial ? _range(80.0, 130.0) : 72.0;
    return PlatformData(
      id: 0,
      position: Vector2(x, y),
      width: width,
    );
  }

  PlatformData generateByArchetype(
    LayoutArchetype archetype,
    int index,
    List<PlatformData> current,
    DifficultyRules rules,
  ) {
    final prev = current.last;
    final width = _randomWidth(rules);
    final gapX = _pickGapX(rules, index);
    final dy = _pickGapY(archetype, index, rules);
    final direction = _pickDirection(archetype, index);

    var x = prev.centerX + (gapX * direction) - width / 2;
    var y = prev.position.y + dy;

    x = x.clamp(safeLeft, safeRight - width);
    y = y.clamp(safeTop, safeBottom);

    return PlatformData(
      id: index,
      position: Vector2(x, y),
      width: width,
    );
  }

  PlatformData applyControlledJitter(
    PlatformData base,
    int index,
    List<PlatformData> current,
    DifficultyRules rules,
  ) {
    const maxJitterX = 14.0;
    const maxJitterY = 10.0;

    var x = base.position.x + _range(-maxJitterX, maxJitterX);
    var y = base.position.y + _range(-maxJitterY, maxJitterY);

    if (index == 0) {
      x = x.clamp(40.0, 110.0);
      y = y.clamp(280.0, 300.0);
    } else {
      x = x.clamp(safeLeft, safeRight - base.width);
      y = y.clamp(safeTop, safeBottom);
    }

    return PlatformData(
      id: base.id,
      position: Vector2(x, y),
      width: base.width,
      isSupportPlatform: base.isSupportPlatform,
    );
  }

  String? validatePhysicalReachability(List<PlatformData> platforms, DifficultyRules rules) {
    if (platforms.isEmpty) return 'physical reachability spawn -> P0\nno platforms generated';

    final firstFailure = _reachabilityFailure(
      label: 'spawn -> P0',
      originX: spawnX + playerWidth / 2,
      originY: groundY,
      target: platforms.first,
      rules: rules,
    );
    if (firstFailure != null) return firstFailure;

    for (var i = 1; i < platforms.length; i++) {
      final prev = platforms[i - 1];
      final curr = platforms[i];
      final failure = _reachabilityFailure(
        label: 'P${prev.id} -> P${curr.id}',
        originX: prev.centerX,
        originY: prev.position.y,
        target: curr,
        rules: rules,
      );
      if (failure != null) return failure;
    }
    return null;
  }

  bool validateMainPath(List<PlatformData> platforms, DifficultyRules rules, LayoutArchetype archetype, int attemptSeed) {
    final reachabilityFailure = validatePhysicalReachability(platforms, rules);
    if (reachabilityFailure != null) {
      _logFailure(attemptSeed, archetype, reachabilityFailure);
      return false;
    }
    if (!validateInsideBounds(platforms)) {
      _logFailure(attemptSeed, archetype, 'inside bounds');
      return false;
    }
    if (!validateVisualQuality(platforms, rules, archetype, attemptSeed)) {
      return false;
    }
    return true;
  }

  bool validateNoOverlap(List<PlatformData> platforms) {
    for (var i = 0; i < platforms.length; i++) {
      for (var j = i + 1; j < platforms.length; j++) {
        final a = platforms[i];
        final b = platforms[j];
        final rectA = Rect.fromLTWH(a.position.x, a.position.y, a.width, a.height);
        final rectB = Rect.fromLTWH(b.position.x, b.position.y, b.width, b.height);
        if (rectA.overlaps(rectB)) return false;
      }
    }
    return true;
  }

  bool validateInsideBounds(List<PlatformData> platforms) {
    for (final p in platforms) {
      if (p.position.x < safeLeft) return false;
      if (p.position.x + p.width > safeRight) return false;
      if (p.position.y < safeTop) return false;
      if (p.position.y > safeBottom) return false;
    }
    return true;
  }

  bool validateVisualQuality(List<PlatformData> platforms, DifficultyRules rules, LayoutArchetype archetype, int attemptSeed) {
    if (platforms.isEmpty) return false;
    final ys = platforms.map((p) => p.position.y).toList()..sort();
    final verticalRange = ys.last - ys.first;
    if (verticalRange < rules.minVerticalRange) {
      _logFailure(attemptSeed, archetype, 'verticalRange too low');
      return false;
    }

    if (_countPlatformsInSameBand(platforms, 16) > 3) {
      _logFailure(attemptSeed, archetype, 'same Y band exceeded');
      return false;
    }
    if (definition.difficulty != Difficulty.tutorial && _gapsTooUniform(platforms)) {
      _logFailure(attemptSeed, archetype, 'gaps too uniform');
      return false;
    }
    if (!_hasRecognizableArchetype(platforms, archetype)) {
      _logFailure(attemptSeed, archetype, 'unrecognizable archetype');
      return false;
    }
    return true;
  }

  List<PlatformData> generateSupportPlatforms(List<PlatformData> mainPath) {
    final supports = <PlatformData>[];
    if (definition.levelNumber < 3 || mainPath.length < 3) return supports;

    for (var i = 1; i < mainPath.length; i += 2) {
      final prev = mainPath[i - 1];
      final curr = mainPath[i];
      final supportY = ((prev.position.y + curr.position.y) / 2).clamp(safeTop, safeBottom - 20);
      final supportWidth = _range(70, 90);
      final supportX = ((prev.centerX + curr.centerX) / 2) - supportWidth / 2;

      final support = PlatformData(
        id: 1000 + i,
        position: Vector2(
          supportX.clamp(safeLeft, safeRight - supportWidth),
          supportY,
        ),
        width: supportWidth,
        isSupportPlatform: true,
      );

      if (validateInsideBounds([support])) {
        supports.add(support);
      }
    }

    return supports;
  }

  List<int> generateDistractors(List<int> correctSequence, int count) {
    final distractors = <int>[];
    var candidate = definition.startValue + 1;
    while (distractors.length < count) {
      if (!correctSequence.contains(candidate) && !distractors.contains(candidate)) {
        distractors.add(candidate);
      }
      candidate++;
      if (candidate > definition.endValue * 3) candidate = definition.startValue + 1;
    }
    return distractors;
  }

  List<StarData> generateStars(
    List<PlatformData> mainPlatforms,
    List<int> correctSequence,
  ) {
    return _generateShuffledStars(mainPlatforms, correctSequence);
  }

  List<StarData> _generateShuffledStars(List<PlatformData> mainPlatforms, List<int> correctSequence) {
    final platformOrder = mainPlatforms.map((p) => p.id).toList()..shuffle(_rng);
    if (_isNaturalOrder(platformOrder)) {
      final first = platformOrder.removeAt(0);
      platformOrder.add(first);
    }

    final stars = <StarData>[];

    for (var i = 0; i < correctSequence.length && i < platformOrder.length; i++) {
      final platformId = platformOrder[i];
      final platform = mainPlatforms.firstWhere(
        (p) => p.id == platformId,
        orElse: () => mainPlatforms[i % mainPlatforms.length],
      );

      stars.add(StarData(
        value: correctSequence[i],
        platformId: platform.id,
        offsetX: platform.width / 2,
        isCorrect: true,
      ));
    }

    return stars;
  }

  bool _isNaturalOrder(List<int> platformOrder) {
    for (var i = 0; i < platformOrder.length; i++) {
      if (platformOrder[i] != i) return false;
    }
    return true;
  }

  String? _reachabilityFailure({
    required String label,
    required double originX,
    required double originY,
    required PlatformData target,
    required DifficultyRules rules,
  }) {
    final targetX = target.centerX;
    final targetY = target.position.y;
    final dx = (targetX - originX).abs();
    final dy = targetY - originY;

    if (dx > rules.maxGapX || dy < 0 && dy.abs() > rules.maxClimbY || dy > 0 && dy > rules.maxDropY) {
      return 'physical reachability $label\n'
          'dx=${dx.toStringAsFixed(1)}\n'
          'dy=${dy.toStringAsFixed(1)}\n'
          'maxGapX=${rules.maxGapX}\n'
          'maxClimbY=${rules.maxClimbY}\n'
          'maxDropY=${rules.maxDropY}';
    }

    return null;
  }

  GeneratedLevel _fallbackLevel1(List<int> correctSequence) {
    final platforms = [
      PlatformData(id: 0, position: Vector2(100, 290), width: 96),
      PlatformData(id: 1, position: Vector2(210, 260), width: 96),
      PlatformData(id: 2, position: Vector2(320, 225), width: 96),
      PlatformData(id: 3, position: Vector2(440, 255), width: 96),
      PlatformData(id: 4, position: Vector2(570, 220), width: 96),
    ];
    final stars = <StarData>[];
    for (var i = 0; i < platforms.length && i < correctSequence.length; i++) {
      stars.add(StarData(
        value: correctSequence[i],
        platformId: platforms[i].id,
        offsetX: 48,
        isCorrect: true,
      ));
    }

    return GeneratedLevel(
      levelNumber: definition.levelNumber,
      title: definition.title,
      seed: seed ?? 0,
      archetype: LayoutArchetype.stairUp,
      platforms: platforms,
      stars: stars,
      correctSequence: correctSequence,
    );
  }

  void _logFailure(int seedValue, LayoutArchetype archetype, String reason) {
  }

  List<StarData> _mergeDistractors(List<StarData> stars, List<int> distractors) {
    if (distractors.isEmpty || stars.isEmpty) return stars;
    final merged = <StarData>[...stars];
    for (var i = 0; i < distractors.length; i++) {
      final base = stars[i % stars.length];
      merged.add(StarData(
        value: distractors[i],
        platformId: base.platformId,
        offsetX: (base.offsetX + _range(-12, 12)).clamp(20, 9999),
        isCorrect: false,
      ));
    }
    return merged;
  }

  double _pickGapX(DifficultyRules rules, int index) {
    final base = _range(rules.minGapX, rules.maxGapX);
    final bias = switch (index % 4) {
      0 => 0.0,
      1 => 8.0,
      2 => -6.0,
      _ => 12.0,
    };
    return (base + bias).clamp(rules.minGapX, rules.maxGapX);
  }

  double _pickGapY(LayoutArchetype archetype, int index, DifficultyRules rules) {
    return switch (archetype) {
      LayoutArchetype.stairUp => -_range(18, rules.maxClimbY),
      LayoutArchetype.stairDown => _range(14, rules.maxDropY),
      LayoutArchetype.zigZag => index.isEven ? -_range(16, rules.maxClimbY) : _range(16, rules.maxDropY),
      LayoutArchetype.peak => _peakDy(index, rules),
      LayoutArchetype.valley => _valleyDy(index, rules),
      LayoutArchetype.mixed => _mixedDy(index, rules),
    };
  }

  double _pickDirection(LayoutArchetype archetype, int index) {
    return switch (archetype) {
      LayoutArchetype.stairUp => 1,
      LayoutArchetype.stairDown => 1,
      LayoutArchetype.zigZag => index.isEven ? 1 : -1,
      LayoutArchetype.peak => index < definition.platformCount ~/ 2 ? 1 : -1,
      LayoutArchetype.valley => index < definition.platformCount ~/ 2 ? 1 : -1,
      LayoutArchetype.mixed => index % 3 == 1 ? -1 : 1,
    };
  }

  double _peakDy(int index, DifficultyRules rules) {
    final mid = definition.platformCount ~/ 2;
    if (index < mid) return -_range(12, rules.maxClimbY);
    if (index == mid) return -_range(0, 12);
    return _range(12, rules.maxDropY);
  }

  double _valleyDy(int index, DifficultyRules rules) {
    final mid = definition.platformCount ~/ 2;
    if (index < mid) return _range(12, rules.maxDropY);
    if (index == mid) return _range(0, 12);
    return -_range(12, rules.maxClimbY);
  }

  double _mixedDy(int index, DifficultyRules rules) {
    switch (index % 5) {
      case 0:
        return -_range(12, rules.maxClimbY);
      case 1:
        return _range(12, rules.maxDropY);
      case 2:
        return -_range(8, rules.maxClimbY);
      case 3:
        return _range(10, rules.maxDropY);
      default:
        return -_range(10, rules.maxClimbY);
    }
  }

  bool _gapsTooUniform(List<PlatformData> platforms) {
    if (platforms.length < 4) return false;
    final gaps = <double>[];
    for (var i = 1; i < platforms.length; i++) {
      gaps.add((platforms[i].centerX - platforms[i - 1].centerX).abs());
    }
    final minGap = gaps.reduce(min);
    final maxGap = gaps.reduce(max);
    if ((maxGap - minGap) < 20) return true;
    var similar = 0;
    for (var i = 1; i < gaps.length; i++) {
      if ((gaps[i] - gaps[i - 1]).abs() < 6) similar++;
    }
    return similar >= gaps.length - 2;
  }

  int _countPlatformsInSameBand(List<PlatformData> platforms, double bandSize) {
    final bands = <int, int>{};
    for (final platform in platforms) {
      final band = (platform.position.y / bandSize).floor();
      bands[band] = (bands[band] ?? 0) + 1;
    }
    return bands.values.fold<int>(0, (maxValue, value) => value > maxValue ? value : maxValue);
  }

  bool _hasRecognizableArchetype(List<PlatformData> platforms, LayoutArchetype archetype) {
    switch (archetype) {
      case LayoutArchetype.stairUp:
        return _isMonotonic(platforms, descending: true);
      case LayoutArchetype.stairDown:
        return _isMonotonic(platforms, descending: false);
      case LayoutArchetype.zigZag:
        return _hasAlternatingMovement(platforms);
      case LayoutArchetype.peak:
        return _hasPeak(platforms);
      case LayoutArchetype.valley:
        return _hasValley(platforms);
      case LayoutArchetype.mixed:
        return true;
    }
  }

  bool _isMonotonic(List<PlatformData> platforms, {required bool descending}) {
    for (var i = 1; i < platforms.length; i++) {
      final dy = platforms[i].position.y - platforms[i - 1].position.y;
      if (descending && dy > 12) return false;
      if (!descending && dy < -12) return false;
    }
    return true;
  }

  bool _hasAlternatingMovement(List<PlatformData> platforms) {
    if (platforms.length < 4) return false;
    var alternations = 0;
    for (var i = 2; i < platforms.length; i++) {
      final prev = platforms[i - 1].position.y - platforms[i - 2].position.y;
      final curr = platforms[i].position.y - platforms[i - 1].position.y;
      if (prev == 0 || curr == 0) continue;
      if (prev.sign != curr.sign) alternations++;
    }
    return alternations >= 2;
  }

  bool _hasPeak(List<PlatformData> platforms) {
    final ys = platforms.map((p) => p.position.y).toList();
    final minY = ys.reduce(min);
    final index = ys.indexOf(minY);
    return index > 0 && index < ys.length - 1;
  }

  bool _hasValley(List<PlatformData> platforms) {
    final ys = platforms.map((p) => p.position.y).toList();
    final maxY = ys.reduce(max);
    final index = ys.indexOf(maxY);
    return index > 0 && index < ys.length - 1;
  }

  double _randomWidth(DifficultyRules rules) {
    return _range(rules.minPlatformWidth, rules.maxPlatformWidth);
  }

  double _range(double minValue, double maxValue) {
    if (maxValue <= minValue) return minValue;
    return minValue + _rng.nextDouble() * (maxValue - minValue);
  }


}
