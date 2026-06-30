# Skipper - Procedural Generation Architecture

## Objetivo

Implementar:

- Procedural Level Generation
- Procedural Star Placement
- Difficulty Progression
- Level Selection Screen
- Save System
- Mathematical Reachability Validation

## Arquitetura

LevelDefinition
↓
DifficultyManager
↓
LevelGenerator
↓
GeneratedLevel
↓
PlatformSpawner
↓
StarSpawner
↓
SkipperGame

## LevelDefinition

```dart
class LevelDefinition {
  final int levelNumber;
  final int skipStep;
  final int startValue;
  final int endValue;
  final int platformCount;
  final int distractorCount;
  final Difficulty difficulty;
}
```

Exemplo:

```dart
LevelDefinition(
  levelNumber: 1,
  skipStep: 2,
  startValue: 2,
  endValue: 10,
  platformCount: 5,
  distractorCount: 0,
  difficulty: Difficulty.tutorial,
);
```

## DifficultyRules

```dart
class DifficultyRules {
  final double minGapX;
  final double maxGapX;
  final double maxClimbY;
  final double maxDropY;
  final int maxAttempts;
}
```

## PlatformData

```dart
class PlatformData {
  final int id;
  final Vector2 position;
  final double width;
  final double height;
}
```

## StarData

```dart
class StarData {
  final int value;
  final int platformId;
  final double offsetX;
  final bool isCorrect;
}
```

## GeneratedLevel

```dart
class GeneratedLevel {
  final List<PlatformData> platforms;
  final List<StarData> stars;
  final List<int> correctSequence;
  final int seed;
}
```

# Geração de Plataformas

Não gerar plataformas aleatórias independentes.

Gerar um caminho navegável:

Spawn
→ P1
→ P2
→ P3
→ P4
→ P5

Cada nova plataforma depende da anterior.

## Fórmula

```dart
dx = random(minGapX, maxGapX);
dy = random(-maxClimbY, maxDropY);

nextX = previousX + dx;
nextY = previousY + dy;
```

## Validações Obrigatórias

- Dentro da tela
- Não sobrepor plataformas existentes
- Ser alcançável pelo jogador
- Respeitar limites de dificuldade

## Reachability

```dart
bool isReachable(
  PlatformData a,
  PlatformData b,
  DifficultyRules rules,
)
```

Validar:

- dx <= maxGapX
- subida <= maxClimbY
- descida <= maxDropY

# Sequências Numéricas

Nível 1

2,4,6,8,10

Nível 2

2,4,6,8,10,12,14,16,18,20

Gerador:

```dart
List<int> generateSequence()
```

# Estrelas

Nunca posicionar sempre no centro.

```dart
offsetX = random(
  20,
  platformWidth - 20,
);
```

Objetivo:

- mesma plataforma
- posições visuais diferentes
- maior sensação de variedade

# Distratores

Exemplo:

Corretos:

2
4
6
8
10

Distratores:

3
5
7
9
11

Regras:

- nunca repetir número correto
- nunca duplicar números
- embaralhar antes de distribuir

# Sistema de Seed

```dart
Random(seed)
```

Benefícios:

- debug
- testes
- ranking
- speedrun
- reprodução de bugs

# Progressão Recomendada

Nível 1 = 5 plataformas
Nível 2 = 6 plataformas
Nível 3 = 7 plataformas
Nível 4 = 8 plataformas
Nível 5 = 10 plataformas
Nível 6 = 12 plataformas
Nível 7 = 14 plataformas
Nível 8 = 16 plataformas
Nível 9 = 18 plataformas
Nível 10 = 20 plataformas

# Tela de Seleção

Inspirada em:

- Super Mario World
- Donkey Kong Country
- Mega Man X

Cada card:

- Nome do nível
- Tipo de contagem
- Melhor tempo
- Status
- Estrelas conquistadas

# Ordem de Implementação

1. LevelDefinition
2. GeneratedLevel
3. DifficultyManager
4. LevelGenerator
5. PlatformSpawner
6. StarSpawner
7. GameState dinâmico
8. LevelSelectScreen
9. ProgressManager
10. SaveManager
11. Distratores
12. Seeds
13. Ranking por nível

# Resultado Esperado

- Sem plataformas fora da tela
- Sem sobreposição
- Sem níveis impossíveis
- Números em posições diferentes
- Progressão escalável
- Suporte a centenas de níveis
