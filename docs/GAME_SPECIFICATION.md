# GAME SPECIFICATION — Skipper

Documento técnico do estado atual do projeto Flutter + Flame e especificação para evolução para geração procedural de plataformas, geração procedural de estrelas, progressão de níveis, tela de seleção de níveis, escalonamento de dificuldade e garantia matemática de níveis completáveis.

Data de análise: 2026-06-24

Projeto analisado localmente

Stack atual:

- Flutter SDK
- Flame `^1.14.0`
- `shared_preferences ^2.2.0`
- Assets locais em `assets/images`, `assets/audio`, `assets/fonts`, `assets/tiles`

---

# 1. Estrutura do Projeto

## 1.1 Árvore de Pastas

```text
lib/
  main.dart
  app.dart
  theme/
    text_styles.dart
  game/
    game_state.dart
    level_data.dart
    skipper_game.dart
    components/
      background_cache.dart
      platform.dart
      player.dart
      star.dart
    config/
      game_config.dart
      palette.dart
    screens/
      game_over_screen.dart
      game_screen.dart
      pause_overlay.dart
      tutorial_overlay.dart
      victory_screen.dart
    ui/
      hud.dart
      keyboard_input.dart
      touch_controls.dart

assets/
  fonts/
    pixel_font.ttf
  images/
    background.png
    hud/
      btn_arrow_left.png
      btn_arrow_right.png
      btn_interact.png
      btn_jump.png
      heart_empty.png
      heart_full.png
      pause_icon.png
    objects/
      plataform.png
      star.png
    player/
      idle.png
      jump.png
      walk.png
  audio/
    music/
      bgm.mp3
    sfx/
      collect_correct.mp3
      collect_wrong.mp3
      game_over.mp3
      jump.mp3
      level_complete.mp3
  tiles/
    map.tmx
    plataform.tmx
```

## 1.2 Arquivos e Responsabilidades

| Arquivo | Responsabilidade Atual |
|---|---|
| `lib/main.dart` | Inicializa Flutter, chama `runApp(const SkipperApp())`. |
| `lib/app.dart` | Cria `MaterialApp`, define `GameScreen` como tela inicial atual. |
| `lib/theme/text_styles.dart` | Define utilitários de texto, principalmente `PixelFont`. |
| `lib/game/config/game_config.dart` | Centraliza constantes de resolução, física, tamanhos, HUD, chão e sequência fixa atual. |
| `lib/game/config/palette.dart` | Centraliza cores usadas por HUD e overlays. |
| `lib/game/game_state.dart` | Estado do jogo: HP, progresso de coleta, pausa, vitória, game over, tempo, tutorial. Atualmente hardcoded para 5 estrelas. |
| `lib/game/level_data.dart` | Estrutura antiga/não integrada para dados de nível. Define `LevelData`, `StarData`, `level1`, `starDataList`. Não é usada por `SkipperGame`. |
| `lib/game/skipper_game.dart` | Classe principal Flame. Cria mundo, background, plataformas, estrelas, player, HUD, controles, keyboard input, overlays e restart. |
| `lib/game/components/background_cache.dart` | `SpriteComponent` que renderiza `background.png` em 800x450. |
| `lib/game/components/platform.dart` | `SpriteComponent` de plataforma. Possui índice, posição base, bobbing vertical e sprite `objects/plataform.png`. |
| `lib/game/components/player.dart` | Componente do jogador: animações, física, input aplicado, colisão com plataformas/chão, coleta, dano, respawn. |
| `lib/game/components/star.dart` | Componente da estrela: sprite, hitbox circular, número renderizado sobre sprite, bobbing vertical. |
| `lib/game/ui/hud.dart` | HUD Flame no viewport: barra superior, corações, botão pause visual, texto de progresso centralizado. |
| `lib/game/ui/keyboard_input.dart` | Entrada por teclado: movimento, pulo, pause e interação. Atualiza input agregado no `SkipperGame`. |
| `lib/game/ui/touch_controls.dart` | Entrada touch: renderiza botões virtuais e atualiza input agregado no `SkipperGame`. |
| `lib/game/screens/game_screen.dart` | Widget Flutter que hospeda `GameWidget`, registra overlays e encaminha eventos de ponteiro ao jogo. |
| `lib/game/screens/pause_overlay.dart` | Overlay Flutter de pausa. |
| `lib/game/screens/victory_screen.dart` | Overlay Flutter de vitória e ranking por `SharedPreferences`. |
| `lib/game/screens/game_over_screen.dart` | Overlay Flutter de game over. |
| `lib/game/screens/tutorial_overlay.dart` | Overlay Flutter de tutorial inicial, removido após 3s ou toque. |

## 1.3 Classes

| Classe | Tipo | Responsabilidade |
|---|---|---|
| `SkipperApp` | Flutter `StatelessWidget` | Raiz do app. |
| `AppTextStyles` | Helper estático | Estilos de texto com `PixelFont`. |
| `GameState` | `ChangeNotifier` | Estado global do nível atual. |
| `LevelData` | Data class antiga | Representa dados de nível fixo, ainda não integrado. |
| `StarData` | Data class antiga | Representa estrela individual, ainda não integrada. |
| `SkipperGame` | `FlameGame` | Orquestra jogo inteiro. |
| `BackgroundComponent` | `SpriteComponent` | Fundo estático. |
| `PlatformComponent` | `SpriteComponent` | Plataforma com bobbing. |
| `PlayerComponent` | `PositionComponent` | Jogador, física, colisões, coleta. |
| `StarComponent` | `PositionComponent with CollisionCallbacks` | Estrela/número coletável. |
| `HUDComponent` | `Component` | HUD desenhado no viewport. |
| `KeyboardInputComponent` | `Component with KeyboardHandler` | Input por teclado. |
| `TouchControlsComponent` | `PositionComponent` | Input touch/render de botões. |
| `GameScreen` | Flutter `StatefulWidget` | Tela do jogo. |
| `PauseOverlay` | Flutter `StatelessWidget` | Overlay de pause. |
| `VictoryOverlay` | Flutter `StatefulWidget` | Overlay de vitória. |
| `GameOverOverlay` | Flutter `StatelessWidget` | Overlay de derrota. |
| `TutorialOverlay` | Flutter `StatefulWidget` | Overlay de tutorial. |
| `Palette` | Classe estática | Paleta de cores. |

## 1.4 Componentes Flame

| Componente | Camada | Observações |
|---|---|---|
| `BackgroundComponent` | `world` | Adicionado primeiro, fica atrás dos demais componentes. |
| `PlatformComponent` | `world` | Plataformas físicas/visuais. |
| `StarComponent` | `world` | Estrelas numeradas coletáveis. |
| `PlayerComponent` | `world` | Jogador e colisões. |
| `HUDComponent` | `camera.viewport` | Fixo na tela, não no mundo. |
| `TouchControlsComponent` | `camera.viewport` | Fixo na tela, não no mundo. |
| `KeyboardInputComponent` | game root | Recebe teclado via `HasKeyboardHandlerComponents<World>`. |

## 1.5 Managers e Services

Não existem managers/services dedicados atualmente.

Funcionalidades que hoje estão embutidas e deveriam virar managers/services:

- Geração de nível: hoje hardcoded em `SkipperGame._generatePlatformLayout()` e `_generateStarPositions()`.
- Progressão/salvamento: parcialmente em `VictoryOverlay` e `SkipperGame._saveRanking()` usando `SharedPreferences`.
- Estado de nível: parcialmente em `GameState`, mas hardcoded para 5 estrelas.
- Dificuldade: inexistente.
- Spawn de plataformas/estrelas: embutido em `SkipperGame.onLoad()`.

## 1.6 Screens e Overlays

Screens:

- `GameScreen`: única tela real atual.

Overlays registrados em `GameScreen`:

```dart
overlayBuilderMap: {
  'pause': (ctx, game) => PauseOverlay(game: game as SkipperGame),
  'victory': (ctx, game) => VictoryOverlay(game: game as SkipperGame),
  'gameOver': (ctx, game) => GameOverOverlay(game: game as SkipperGame),
  'tutorial': (ctx, game) => TutorialOverlay(game: game as SkipperGame),
}
```

---

# 2. Resolução do Jogo

## 2.1 Valores Reais Encontrados

Arquivo: `lib/game/config/game_config.dart`

```dart
const double virtualWidth = 800;
const double virtualHeight = 450;
```

## 2.2 `game.size.x` e `game.size.y`

O jogo usa câmera com resolução fixa:

```dart
camera: CameraComponent.withFixedResolution(
  width: config.virtualWidth,
  height: config.virtualHeight,
  viewfinder: Viewfinder()..anchor = Anchor.topLeft,
)
```

Resolução lógica pretendida:

- `game.size.x`: depende do canvas físico em runtime.
- `game.size.y`: depende do canvas físico em runtime.
- Resolução lógica usada pela câmera: `800 x 450`.

Em Flame, `game.size` representa o tamanho físico disponível para o jogo. A câmera fixa mapeia esse tamanho para uma área lógica de 800x450.

## 2.3 Viewport, Camera e World

Classe principal:

```dart
class SkipperGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents<World> {
```

Camera:

- `CameraComponent.withFixedResolution(width: 800, height: 450)`.
- `viewfinder.anchor = Anchor.topLeft`.

World:

- `FlameGame` usa `world` padrão.
- Background, plataformas, estrelas e player são adicionados a `world`.
- HUD e controles são adicionados a `camera.viewport`.

Viewport equivalente:

- O projeto usa `CameraComponent.withFixedResolution`, que internamente fornece comportamento de viewport de resolução fixa equivalente ao antigo conceito de `FixedResolutionViewport`.

## 2.4 Área Jogável Atual

Constantes relevantes:

```dart
const double hudHeight = 25;
const double groundY = 370;
```

Área lógica total:

- X: `0..800`
- Y: `0..450`

Área jogável recomendada para procedural generation:

- X mínimo: `30`
- X máximo: `770`
- Y mínimo útil: `hudHeight + margem = 25 + 30 = 55`
- Y máximo para plataformas: `groundY - playerHeight - platformHeight` ou menor, recomendado `280`.
- Chão sólido conceitual: bloco de `800x80`, topo em `Y=370`, fundo em `Y=450`.

---

# 3. Jogador

## 3.1 Classe

Arquivo: `lib/game/components/player.dart`

```dart
class PlayerComponent extends PositionComponent {
```

## 3.2 Tamanho

Arquivo: `lib/game/config/game_config.dart`

```dart
const double playerWidth = 25;
const double playerHeight = 44;
```

No construtor:

```dart
PlayerComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(config.playerWidth, config.playerHeight),
        anchor: Anchor.topLeft,
      );
```

## 3.3 Hitbox

```dart
const double playerHitboxX = 4;
const double playerHitboxY = 4;
const double playerHitboxW = 17;
const double playerHitboxH = 36;
```

Aplicação:

```dart
add(RectangleHitbox(
  size: Vector2(config.playerHitboxW, config.playerHitboxH),
  position: Vector2(config.playerHitboxX, config.playerHitboxY),
));
```

Hitbox real relativa ao componente:

- X: `4..21`
- Y: `4..40`
- Largura: `17`
- Altura: `36`

## 3.4 Física

Arquivo: `lib/game/config/game_config.dart`

```dart
const double gravity = 1980.0;
const double gravityHold = 900.0;
const double jumpVelocity = -570.0;
const double moveSpeed = 180.0;
const double maxFallSpeed = 720.0;
const double friction = 0.85;
const double jumpCutMultiplier = 0.4;
const double coyoteTime = 0.1;
```

Correspondência dos nomes pedidos:

| Nome pedido | Valor real atual |
|---|---:|
| `gravity` | `1980 px/s²` |
| `jumpForce` | `jumpVelocity = -570 px/s` |
| `velocity` | `moveSpeed = 180 px/s` horizontal |
| `terminalVelocity` | `maxFallSpeed = 720 px/s` |

## 3.5 Movimento

Trecho real:

```dart
if (_moveLeftHeld) {
  vx = -config.moveSpeed;
} else if (_moveRightHeld) {
  vx = config.moveSpeed;
} else {
  vx = 0;
}
```

Movimento horizontal:

- Esquerda: `vx = -180 px/s`
- Direita: `vx = 180 px/s`
- Sem input: `vx = 0`

Movimento vertical:

```dart
final grav = (isHoldingJump && !isGrounded) ? config.gravityHold : config.gravity;
vy += grav * dt;
vy = vy.clamp(-double.infinity, config.maxFallSpeed);
```

Pulo:

```dart
vy = config.jumpVelocity;
isGrounded = false;
isHoldingJump = true;
_coyoteTimer = 999;
```

Pulo variável:

```dart
if (!_jumpHeld && isHoldingJump && vy < 0) {
  vy *= config.jumpCutMultiplier;
  isHoldingJump = false;
}
```

Aceleração horizontal:

- Não há aceleração gradual.
- Velocidade horizontal é instantânea.

Desaceleração horizontal:

- Não há desaceleração gradual.
- Ao soltar input, `vx = 0` imediatamente.

Constante `friction = 0.85` existe, mas não é usada atualmente.

---

# 4. Alcance Real do Pulo

## 4.1 Convenções

Sistema de coordenadas Flame:

- X cresce para direita.
- Y cresce para baixo.
- Pulo usa velocidade vertical negativa (`jumpVelocity = -570`).
- Gravidade aumenta `vy` positivamente.

Valores reais:

- `v0 = 570 px/s` em módulo.
- `gHold = 900 px/s²` enquanto segura pulo.
- `gNormal = 1980 px/s²` se pulo for cortado/sem segurar.
- `moveSpeed = 180 px/s`.
- `maxFallSpeed = 720 px/s`.

## 4.2 Fórmula de Altura Máxima

Para movimento vertical com aceleração constante:

```text
h = v0² / (2g)
```

## 4.3 Altura Máxima Segurando Pulo

```text
h_hold = 570² / (2 * 900)
h_hold = 324900 / 1800
h_hold = 180.5 px
```

Altura máxima teórica segurando pulo: **180.5 px**.

## 4.4 Altura Máxima com Pulo Curto

Se o jogador solta rapidamente, `vy *= jumpCutMultiplier`.

Logo:

```text
v_cut = 570 * 0.4 = 228 px/s
h_cut = 228² / (2 * 1980)
h_cut = 51984 / 3960
h_cut = 13.13 px
```

No caso real de um toque curto, existe pelo menos alguns frames antes do corte, então a altura observada será maior que 13px, mas a fórmula mostra o limite após corte imediato.

## 4.5 Altura Máxima com Gravidade Normal Sem Hold

Se considerar o pulo inteiro sob gravidade normal:

```text
h_normal = 570² / (2 * 1980)
h_normal = 324900 / 3960
h_normal = 82.05 px
```

Altura máxima sem hold prolongado: **aprox. 82 px**.

## 4.6 Tempo até o Ápice Segurando Pulo

```text
t_up = v0 / gHold
t_up = 570 / 900
t_up = 0.633 s
```

## 4.7 Tempo de Queda de Volta à Mesma Altura

Após o ápice, gravidade normal é usada quando `isHoldingJump` deixa de ser relevante no topo ou quando o jogador não está segurando. Para queda de `h = 180.5`:

```text
t_down = sqrt(2h / gNormal)
t_down = sqrt(361 / 1980)
t_down = sqrt(0.1823)
t_down = 0.427 s
```

Tempo total aproximado até voltar ao mesmo Y:

```text
t_total = 0.633 + 0.427 = 1.060 s
```

## 4.8 Distância Horizontal Máxima Correndo e Pulando

```text
dx = moveSpeed * t_total
dx = 180 * 1.060
dx = 190.8 px
```

Distância horizontal máxima teórica em pulo completo: **aprox. 190 px**.

Para geração procedural segura, deve-se usar margem conservadora menor:

- `maxSafeGapX = 130 px` recomendado.
- `minGapX = 80 px` recomendado para evitar plataformas coladas.

## 4.9 Distância Vertical Máxima

Subida teórica segurando pulo:

- `180.5 px`

Subida segura para geração:

- `maxClimbY = 80 px`

Descida segura para leitura visual e controle:

- `maxDropY = 60 px`

Motivo: mesmo que fisicamente o player consiga subir mais, plataformas geradas no limite tornam o nível frustrante e sensível ao timing. A especificação deve usar limites conservadores.

## 4.10 Cenários

Jogador parado:

- `dx = 0`
- Pode subir até ~180px segurando pulo.
- Para design seguro, considerar subida útil de 80px.

Jogador correndo:

- `dx` teórico até ~190px.
- Para design seguro, limitar a 130px.

Jogador pulando:

- Pulo full-hold dá altura alta.
- Pulo curto fica muito menor por `jumpCutMultiplier`.
- Coyote time atual: `0.1s`.

---

# 5. Plataformas

## 5.1 Classe

Arquivo: `lib/game/components/platform.dart`

```dart
class PlatformComponent extends SpriteComponent {
```

## 5.2 Tamanho Atual

Arquivo: `game_config.dart`

```dart
const double platformWidth = 96;
const double platformHeight = 16;
```

Aplicado no construtor:

```dart
size: Vector2(config.platformWidth, config.platformHeight),
```

## 5.3 Colisão

Não há `Hitbox` no `PlatformComponent`.

Colisão é manual no player:

```dart
if (vy > 0 &&
    y + height >= platform.y &&
    _previousBottom <= platform.y + 4 &&
    x + width > platform.x &&
    x < platform.x + platform.width) {
  y = platform.y - height;
  vy = 0;
  isGrounded = true;
  _coyoteTimer = 0;
  state?.lastPlatformIndex = platform.index;
}
```

Interpretação:

- Só colide caindo (`vy > 0`).
- O player deve cruzar o topo da plataforma.
- Há tolerância vertical de 4px: `_previousBottom <= platform.y + 4`.
- Overlap horizontal é AABB simples.

## 5.4 Sprite

```dart
sprite = await Sprite.load('objects/plataform.png');
```

Asset real:

- `assets/images/objects/plataform.png`

## 5.5 Anchor

`SpriteComponent` usa `Anchor.topLeft` por padrão quando não definido.

## 5.6 Layer

Adicionada ao `world` após background e antes das estrelas/player.

Ordem em `SkipperGame.onLoad()`:

```dart
world.add(BackgroundComponent());
// plataformas
// estrelas
// player
```

## 5.7 Prioridade

Nenhum `priority` explícito é definido.

Render order segue ordem de adição ao `world`.

## 5.8 Bobbing Atual

```dart
bobPhase += dt * 1.25;
y = basePosition.y + 3 * sin(bobPhase);
```

Amplitude vertical: `±3 px`.

---

# 6. Estrelas

## 6.1 Classe

Arquivo: `lib/game/components/star.dart`

```dart
class StarComponent extends PositionComponent with CollisionCallbacks {
```

## 6.2 Tamanho

```dart
const double starSize = 25;
```

No construtor:

```dart
size: Vector2(config.starSize, config.starSize),
anchor: Anchor.center,
```

## 6.3 Colisão

```dart
add(CircleHitbox(radius: config.starInteractionRadius));
```

Valor:

```dart
const double starInteractionRadius = 22;
```

Observação: o raio `22` é maior que a estrela visual `25x25`. Como a estrela usa anchor center e o hitbox é adicionado sem offset explícito, isso deve ser revisado futuramente para casar hitbox e visual.

## 6.4 Offset em Relação à Plataforma

Atualmente `SkipperGame._generateStarPositions()` calcula:

```dart
Vector2(
  p.x + config.platformWidth / 2,
  p.y - config.starSize / 2,
)
```

Logo:

- `x = centro da plataforma`
- `y = topo da plataforma - metade da estrela`
- Como a estrela tem `Anchor.center`, a base visual da estrela encosta no topo da plataforma antes do bobbing.

Depois, `StarComponent.update()` aplica bobbing:

```dart
x = _basePosition.x;
y = _basePosition.y + 4 * sin(bobPhase);
```

Amplitude: `±4 px`.

## 6.5 Como os Números São Exibidos

Trecho real:

```dart
final textPainter = TextPainter(
  text: TextSpan(
    text: number.toString(),
    style: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontFamily: 'PixelFont',
      shadows: const [
        Shadow(offset: Offset(1, 1), blurRadius: 2, color: Color(0x80000000))
      ],
    ),
  ),
  textDirection: TextDirection.ltr,
);
textPainter.layout();
textPainter.paint(
  canvas,
  Offset((width - textPainter.width) / 2, (height - textPainter.height) / 2),
);
```

Número:

- Branco.
- Fonte `PixelFont`.
- Tamanho `12px`.
- Centralizado dentro do retângulo 25x25.
- Sombra preta translúcida.

## 6.6 Como o Valor da Estrela é Definido

Atual:

```dart
StarComponent(
  number: config.correctSequence[i],
  starIndex: i,
  position: _starPositions[i].clone(),
  bobPhase: _random.nextDouble() * pi * 2,
)
```

Ou seja:

- Valor vem de `config.correctSequence[i]`.
- Não existem distratores atualmente.
- A quantidade de estrelas depende da quantidade de plataformas hardcoded, mas `correctSequence` tem 5 elementos, então o sistema atual assume 5 plataformas/5 estrelas.

---

# 7. Sistema de Contagem

## 7.1 Regra Atual do Skip Count

Arquivo: `game_config.dart`

```dart
const List<int> correctSequence = [2, 4, 6, 8, 10];
```

O nível atual ensina contagem de 2 em 2 até 10.

## 7.2 Como o Jogador Vence

Em `GameState.collectStar()`:

```dart
void collectStar(int number) {
  collectedNumbers.add(number);
  starsCollected[collectedIndex] = true;
  collectedIndex++;
  notifyListeners();
  if (collectedIndex >= config.correctSequence.length) {
    isVictory = true;
    notifyListeners();
  }
}
```

Vitória ocorre quando:

```text
collectedIndex >= correctSequence.length
```

Atualmente `correctSequence.length = 5`.

## 7.3 Como o Jogador Perde

Perde HP ao coletar estrela errada ou cair.

Coleta errada em `PlayerComponent.interact()`:

```dart
if (nearestStar.number == expectedNumber) {
  state.collectStar(nearestStar.number);
  nearestStar.isCollected = true;
} else {
  state.loseHP();
  _startDamageAnimation();
}
```

Queda em `PlayerComponent._checkFall()`:

```dart
if (y > config.virtualHeight) {
  _game?.state.loseHP();
  _respawn();
  _startDamageAnimation();
}
```

Game over em `GameState.loseHP()`:

```dart
void loseHP() {
  _currentHP--;
  notifyListeners();
  if (_currentHP <= 0) {
    isGameOver = true;
    notifyListeners();
  }
}
```

HP inicial:

```dart
const int maxHP = 3;
```

## 7.4 Como os Números das Estrelas São Gerados

Atualmente não são gerados proceduralmente.

Eles vêm diretamente de:

```dart
config.correctSequence[i]
```

Consequência:

- Não há números incorretos/distratores.
- Todas as estrelas são corretas.
- O desafio é apenas coletar na ordem esperada.

## 7.5 Exemplos de Sequências Futuras

Contagem de 2 em 2:

```text
2, 4, 6, 8, 10, 12, 14, 16, 18, 20
```

Contagem de 3 em 3:

```text
3, 6, 9, 12, 15, 18, 21, 24, 27, 30
```

Contagem de 5 em 5:

```text
5, 10, 15, 20, 25, 30, 35, 40, 45, 50
```

Contagem de 10 em 10:

```text
10, 20, 30, 40, 50, 60, 70, 80, 90, 100
```

---

# 8. Sistema de Níveis Atual

## 8.1 Quantidade de Níveis

Atualmente há apenas 1 nível jogável real.

## 8.2 Como é Carregado

`app.dart` carrega direto `GameScreen`:

```dart
home: const GameScreen(),
```

`GameScreen` cria jogo sem parâmetros:

```dart
final SkipperGame _game = SkipperGame();
```

`SkipperGame.onLoad()` cria tudo hardcoded.

## 8.3 Onde Está Definido

Plataformas hardcoded:

```dart
List<Vector2> _generatePlatformLayout() {
  return [
    Vector2(95, 249),
    Vector2(232, 192),
    Vector2(367, 265),
    Vector2(496, 143),
    Vector2(621, 241),
  ];
}
```

Estrelas derivadas das plataformas:

```dart
List<Vector2> _generateStarPositions() {
  return [
    for (final p in _platformLayout)
      Vector2(
        p.x + config.platformWidth / 2,
        p.y - config.starSize / 2,
      ),
  ];
}
```

Sequência hardcoded:

```dart
const List<int> correctSequence = [2, 4, 6, 8, 10];
```

Arquivo antigo com dados de nível não usado:

```dart
final level1 = LevelData(
  levelName: 'Contar de 2 em 2',
  sequence: [2, 4, 6, 8, 10],
  starPositions: [...],
  platformPositions: [...],
);
```

---

# 9. HUD

## 9.1 Vidas

Corações em `HUDComponent`:

```dart
for (var i = 0; i < config.maxHP; i++) {
  final heart = SpriteComponent(
    sprite: heartFull,
    size: Vector2(config.heartSize, config.heartSize),
    position: Vector2(16 + i * 28, 3),
  );
  _hearts.add(heart);
  add(heart);
}
```

Valores:

- `maxHP = 3`
- `heartSize = 20`
- Posições: `(16,3)`, `(44,3)`, `(72,3)`.

Efeito de piscar ao dano:

```dart
final isFlashingHeart = i == state.currentHP && game.player.isInvincible;
if (isFlashingHeart) {
  final phase = (game.player.damageTimer / 0.12).floor() % 2;
  _hearts[i].sprite = phase == 0 ? game.heartFullSprite : game.heartEmptySprite;
} else {
  _hearts[i].sprite = i < state.currentHP ? game.heartFullSprite : game.heartEmptySprite;
}
```

## 9.2 Score

Não existe score numérico.

O progresso é a sequência exibida no topo:

```text
 2  -  4  -  6  -  8  -  10
```

Itens coletados aparecem entre colchetes:

```text
[2] -  4  -  6  -  8  -  10
```

## 9.3 Contador

Timer ainda existe internamente em `GameState.elapsedTime` e `SkipperGame.update()`, mas não é mais renderizado no HUD.

No estado:

```dart
Duration elapsedTime = Duration.zero;
```

No update:

```dart
if (_timerRunning) {
  state.elapsedTime += Duration(milliseconds: (dt * 1000).round());
}
```

No overlay de vitória ainda é exibido:

```dart
Text('Seu tempo: $timeStr')
```

## 9.4 Pause

Botão visual no HUD:

```dart
final pauseBtn = SpriteComponent(
  sprite: pauseSprite,
  size: Vector2(config.pauseButtonSize, config.pauseButtonSize),
  position: Vector2(764, 3),
);
```

Área touch real para pause:

```dart
if (pos.x >= 746 && pos.x <= 794 && pos.y >= 2 && pos.y <= 50) {
  game.togglePause();
  return;
}
```

Teclado:

- `Escape`
- `P`

## 9.5 Overlays

- `pause`: pausa.
- `victory`: vitória.
- `gameOver`: derrota.
- `tutorial`: tutorial inicial.

---

# 10. Spawn Atual

## 10.1 Código que Cria Plataformas

Arquivo: `lib/game/skipper_game.dart`

```dart
for (var i = 0; i < _platformLayout.length; i++) {
  world.add(PlatformComponent(
    index: i,
    position: Vector2(
      _platformLayout[i].x,
      _platformLayout[i].y,
    ),
    bobPhase: _random.nextDouble() * pi * 2,
  ));
}
```

## 10.2 Código que Posiciona Plataformas

```dart
List<Vector2> _generatePlatformLayout() {
  return [
    Vector2(95, 249),
    Vector2(232, 192),
    Vector2(367, 265),
    Vector2(496, 143),
    Vector2(621, 241),
  ];
}
```

Posições atuais:

| Índice | X | Y | Width | Height |
|---:|---:|---:|---:|---:|
| 0 | 95 | 249 | 96 | 16 |
| 1 | 232 | 192 | 96 | 16 |
| 2 | 367 | 265 | 96 | 16 |
| 3 | 496 | 143 | 96 | 16 |
| 4 | 621 | 241 | 96 | 16 |

## 10.3 Código que Cria Estrelas

```dart
for (var i = 0; i < _platformLayout.length; i++) {
  world.add(StarComponent(
    number: config.correctSequence[i],
    starIndex: i,
    position: _starPositions[i].clone(),
    bobPhase: _random.nextDouble() * pi * 2,
  ));
}
```

## 10.4 Código que Posiciona Estrelas

```dart
List<Vector2> _generateStarPositions() {
  return [
    for (final p in _platformLayout)
      Vector2(
        p.x + config.platformWidth / 2,
        p.y - config.starSize / 2,
      ),
  ];
}
```

Posições calculadas atuais antes do bobbing:

| Índice | Plataforma | Fórmula | Star X | Star Y |
|---:|---|---|---:|---:|
| 0 | (95,249) | `(95 + 48, 249 - 12.5)` | 143 | 236.5 |
| 1 | (232,192) | `(232 + 48, 192 - 12.5)` | 280 | 179.5 |
| 2 | (367,265) | `(367 + 48, 265 - 12.5)` | 415 | 252.5 |
| 3 | (496,143) | `(496 + 48, 143 - 12.5)` | 544 | 130.5 |
| 4 | (621,241) | `(621 + 48, 241 - 12.5)` | 669 | 228.5 |

## 10.5 Código de Spawn do Player

Inicial:

```dart
player = PlayerComponent(
  position: Vector2(36, 326),
);
world.add(player);
```

Restart:

```dart
player.position.setValues(36, 326);
player.vy = 0;
player.vx = 0;
player.isGrounded = true;
player.isHoldingJump = false;
```

Relação com chão:

```text
groundY = 370
playerHeight = 44
spawnY = 370 - 44 = 326
```

Portanto a base do player nasce exatamente no topo do bloco sólido de chão 800x80.

---

# 11. Constraints para Procedural Generation

## 11.1 Baseado na Física Real

Valores reais:

- `moveSpeed = 180 px/s`
- `jumpVelocity = 570 px/s` em módulo
- `gravityHold = 900 px/s²`
- `gravity = 1980 px/s²`
- Altura teórica full jump: `180.5px`
- Distância horizontal teórica full jump para mesma altura: `190.8px`

## 11.2 Distância Horizontal Segura

Embora o alcance teórico seja ~190px, a geração deve usar margem conservadora.

Recomendado:

```dart
const double minGapX = 80;
const double maxGapX = 130;
```

Motivo:

- `130 < 190.8`, deixa margem de ~60px.
- Evita saltos pixel-perfect.
- Mantém desafio adequado para criança/educacional.

## 11.3 Distância Vertical Segura

Recomendado:

```dart
const double maxClimbY = 80; // subir
const double maxDropY = 60;  // descer
```

Motivo:

- `80 < 180.5`, muito seguro para subida.
- Quedas de até 60px são visualmente fáceis de ler.
- Reduz chance de plataforma fora do campo de atenção.

## 11.4 Área Jogável Recomendada

```dart
const double safeMarginX = 30;
const double minPlatformY = 80;
const double maxPlatformY = 280;
const double groundTopY = 370;
```

Limites para plataformas:

```text
x >= 30
x + width <= 770
y >= max(hudHeight + 30, 55)
y <= 280
```

Alturas preferenciais:

```dart
const allowedY = [80, 120, 160, 200, 240, 280];
```

## 11.5 Sobreposição

Regras:

- Plataforma não pode invadir bounding box de outra.
- Distância horizontal mínima recomendada entre centros: `100px`.
- Distância vertical mínima recomendada se X estiver próximo: `60px`.
- Estrela ocupa `25x25` e boba `±4px`, então reservar caixa vertical de `33px` (`25 + 8`).

---

# 12. Proposta de Geração Procedural

## 12.1 Especificação Técnica Geral

Gerar níveis usando `LevelDefinition` + `LevelGenerator`.

Cada nível define:

- `levelNumber`
- `skipStep`
- `startValue`
- `targetValue`
- `platformCount`
- `starCount`
- `correctCount`
- `difficulty`
- `maxGapX`
- `maxClimbY`
- `maxDropY`
- `distractorCount`

## 12.2 Tabela de 10 Níveis

| Nível | Contagem | Plataformas | Estrelas | Números corretos | Dificuldade | maxGapX | maxClimbY | maxDropY |
|---:|---|---:|---:|---:|---|---:|---:|---:|
| 1 | 2 até 10 | 5 | 5 | 5 | Tutorial | 90 | 40 | 40 |
| 2 | 2 até 20 | 10 | 10 | 10 | Fácil | 100 | 50 | 45 |
| 3 | 3 até 30 | 10 | 10 | 10 | Fácil+ | 105 | 55 | 45 |
| 4 | 5 até 50 | 10 | 10 | 10 | Médio | 110 | 60 | 50 |
| 5 | 2 até 30 com distratores | 12 | 12 | 15 possíveis, 10 usadas | Médio | 115 | 65 | 50 |
| 6 | 3 até 45 com distratores | 12 | 12 | 15 possíveis, 10 usadas | Médio+ | 120 | 70 | 55 |
| 7 | 5 até 75 com distratores | 15 | 15 | 15 possíveis, 12 usadas | Difícil | 125 | 75 | 55 |
| 8 | 10 até 100 | 15 | 15 | 10 corretas + 5 distratores | Difícil | 130 | 80 | 60 |
| 9 | 4 até 80 misto | 18 | 18 | 15 corretas + 3 distratores | Difícil+ | 130 | 80 | 60 |
| 10 | Revisão 2/3/5/10 | 20 | 20 | 16 corretas + 4 distratores | Master | 130 | 80 | 60 |

## 12.3 Nível 1

- Contagem: `2,4,6,8,10`
- Plataformas: `5`
- Estrelas: `5`
- Distratores: `0`
- maxGapX: `90`
- maxClimbY: `40`
- maxDropY: `40`
- Objetivo: ensinar fluxo básico sem punição cognitiva forte.

## 12.4 Nível 2

- Contagem: `2,4,6,8,10,12,14,16,18,20`
- Plataformas: `10`
- Estrelas: `10`
- Distratores: `0`
- maxGapX: `100`
- maxClimbY: `50`
- maxDropY: `45`

## 12.5 Níveis 3 a 10

Aumentar gradualmente:

- Número de plataformas.
- Número de estrelas.
- Presença de distratores.
- Variação vertical.
- Gaps horizontais.
- Contagens com passos maiores.

Garantia: mesmo no nível 10, `maxGapX = 130`, `maxClimbY = 80`, `maxDropY = 60`, todos abaixo dos limites reais calculados.

---

# 13. Sistema Anti-Níveis-Impossíveis

## 13.1 Objetivos

Garantir:

- Nenhuma plataforma fora da tela.
- Nenhuma plataforma sobreposta.
- Nenhuma estrela fora da plataforma.
- Nenhuma estrela sobreposta.
- Sempre existir caminho até o objetivo.
- Sempre existir sequência válida para completar o nível.

## 13.2 Algoritmo Recomendado

Passo 1 — Definir área segura:

```dart
safeLeft = 30;
safeRight = 770;
safeTop = hudHeight + 30;
safeBottom = groundY - 60;
```

Passo 2 — Criar primeira plataforma ou spawn no chão:

- Opção A: player começa no chão e primeira plataforma fica alcançável a partir do chão.
- Opção B: player começa na primeira plataforma.

Recomendação: para nível 1, player no chão. Para níveis avançados, permitir spawn em plataforma inicial.

Passo 3 — Gerar cadeia principal:

```text
platform[i] depende de platform[i - 1]
```

Cada candidato deve respeitar:

```dart
dx >= minGapX
dx <= maxGapX
dyUp <= maxClimbY
dyDown <= maxDropY
x >= safeLeft
x + width <= safeRight
y >= safeTop
y <= safeBottom
```

Passo 4 — Validar contra todas as plataformas anteriores:

```dart
bool intersects = rectA.overlaps(rectB.inflate(10));
bool tooCloseX = (centerA.x - centerB.x).abs() < 100;
bool tooCloseY = (centerA.y - centerB.y).abs() < 60;
```

Se `intersects` ou (`tooCloseX && tooCloseY`), rejeitar candidato.

Passo 5 — Tentativas e fallback:

- Tentar até 30 candidatos por plataforma.
- Se falhar, reduzir dificuldade temporariamente:
  - `maxGapX -= 10`
  - `maxClimbY -= 10`
  - priorizar Y igual/anterior
- Se ainda falhar, reiniciar o nível com nova seed.

Passo 6 — Estrela por plataforma:

```dart
star.x = platform.x + platform.width / 2;
star.y = platform.y - starSize / 2;
```

Caixa de segurança da estrela:

```dart
Rect.fromCenter(
  center: star.position,
  width: starSize,
  height: starSize + 8, // bobbing
)
```

Passo 7 — Validar estrelas:

- Estrela deve estar dentro da tela.
- Estrela não pode invadir HUD.
- Estrela não pode sobrepor outra estrela.
- Estrela não pode sobrepor plataforma que não seja a sua.

Passo 8 — Sequência válida:

- Gerar lista correta ordenada.
- Distribuir nas plataformas em ordem de caminho ou embaralhar visualmente com regra de coleta.
- Para garantir completabilidade cognitiva, a sequência correta deve existir exatamente uma vez por valor.
- Distratores não podem repetir números corretos.

Passo 9 — Validação final do caminho:

Construir grafo dirigido:

- Nó: plataforma.
- Aresta `A -> B`: se `B` é alcançável a partir de `A` pela função `_isReachable`.

Garantir:

```text
start -> p0 -> p1 -> ... -> pn
```

Como a geração é sequencial, basta validar cada par consecutivo. Para níveis com branching, rodar BFS/DFS.

## 13.3 Funções Essenciais

```dart
bool isReachable(PlatformData a, PlatformData b, DifficultyRules rules) {
  final dx = (b.centerX - a.centerX).abs();
  final dy = b.y - a.y;
  final goingUp = dy < 0;
  final goingDown = dy > 0;

  if (dx > rules.maxGapX) return false;
  if (goingUp && dy.abs() > rules.maxClimbY) return false;
  if (goingDown && dy.abs() > rules.maxDropY) return false;
  return true;
}
```

---

# 14. Tela de Seleção de Níveis

## 14.1 Estilo Visual

Inspirada em jogos 16-bit SNES:

- Fundo com parallax simples ou imagem do mundo escurecida.
- Painel central com borda pixelada.
- Fonte `PixelFont`.
- Cards com sombra e borda clara.
- Ícones: estrela para concluído, cadeado para bloqueado.
- Seleção atual com brilho/pulso.

## 14.2 Layout

Resolução lógica: 800x450.

Wireframe ASCII:

```text
┌────────────────────────────────────────────────────────────┐
│                    SKIPPER - LEVEL SELECT                 │
│                                                            │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  │
│  │  ★ NÍVEL 01   │  │  ★ NÍVEL 02   │  │  🔒 NÍVEL 03  │  │
│  │  2 EM 2       │  │  2 ATÉ 20     │  │  3 EM 3       │  │
│  │  COMPLETO     │  │  ABERTO       │  │  BLOQUEADO    │  │
│  └───────────────┘  └───────────────┘  └───────────────┘  │
│                                                            │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  │
│  │  🔒 NÍVEL 04  │  │  🔒 NÍVEL 05  │  │  🔒 NÍVEL 06  │  │
│  └───────────────┘  └───────────────┘  └───────────────┘  │
│                                                            │
│         ← / → selecionar       ENTER / TOQUE jogar         │
└────────────────────────────────────────────────────────────┘
```

## 14.3 Navegação

- Mouse/touch: tocar no card.
- Teclado: setas movem seleção, Enter inicia.
- ESC volta se houver menu anterior.

## 14.4 Progressão

- Nível 1 desbloqueado por padrão.
- Ao concluir nível N, desbloquear N+1.
- Armazenar melhor tempo por nível.
- Armazenar status concluído.

## 14.5 Salvamento

Usar `SharedPreferences` inicialmente:

```text
skipper_level_unlocked = int
skipper_level_1_completed = bool
skipper_level_1_best_time = String
skipper_level_1_best_seed = int
```

Futuro: migrar para arquivo JSON/local DB se houver centenas de níveis.

---

# 15. Plano de Refatoração

## 15.1 Objetivo

Migrar de nível hardcoded para:

- Procedural Level Generation
- Level Selection Screen
- Difficulty Progression
- Salvamento de progresso
- Garantia matemática de completabilidade

## 15.2 Etapas

### Etapa 1 — Introduzir Modelo de Nível

Criar:

- `lib/game/levels/level_definition.dart`
- `lib/game/levels/level_data.dart`
- `lib/game/levels/generated_level_data.dart`

Migrar `LevelData` antigo para nova estrutura.

Risco: conflito de nome com `lib/game/level_data.dart` atual.

Mitigação: remover ou transformar arquivo antigo em export.

### Etapa 2 — Tornar `GameState` Dinâmico

Alterar:

- `starsCollected = List.filled(levelData.numbers.length, false)`
- `correctSequence` vindo do nível
- `maxHP` vindo do nível ou default config

Arquivos afetados:

- `game_state.dart`
- `player.dart`
- `hud.dart`

### Etapa 3 — Criar `LevelGenerator`

Criar:

- `lib/game/levels/level_generator.dart`

Implementar:

- RNG com seed.
- Cadeia principal alcançável.
- Validação anti-overlap.
- Distribuição de números.

### Etapa 4 — Criar Spawners

Criar:

- `PlatformSpawner`
- `StarSpawner`

Remover criação direta de `SkipperGame.onLoad()`.

### Etapa 5 — Adaptar `PlatformComponent`

Permitir width variável:

```dart
PlatformComponent({required double width, ...})
```

### Etapa 6 — Adaptar `SkipperGame`

Construtor:

```dart
SkipperGame({required this.levelData})
```

Responsabilidades:

- Carregar `levelData`.
- Spawnar componentes via spawners.
- Restart do mesmo nível.

### Etapa 7 — Criar `LevelSelectScreen`

Criar tela Flutter antes do jogo.

Alterar `app.dart`:

```dart
home: const LevelSelectScreen(),
```

### Etapa 8 — Criar `ProgressManager` e `SaveManager`

Responsáveis por:

- Níveis desbloqueados.
- Níveis concluídos.
- Melhor tempo.
- Última seed.

### Etapa 9 — Atualizar Overlays

Adicionar botões:

- Vitória: `PRÓXIMO NÍVEL`, `SELEÇÃO DE NÍVEIS`, `REJOGAR`.
- GameOver: `TENTAR NOVAMENTE`, `SELEÇÃO DE NÍVEIS`.

### Etapa 10 — Testes de Garantia

Criar testes para:

- 1000 níveis gerados por seed.
- Nenhuma plataforma fora da tela.
- Nenhuma plataforma sobreposta.
- Toda plataforma consecutiva alcançável.
- Todas as estrelas dentro da tela.
- Sequência correta completa.

## 15.3 Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| Física real diferente da estimada | Níveis impossíveis | Usar limites conservadores e testes massivos. |
| Hitbox da estrela maior que sprite | Coleta inesperada | Ajustar raio para `starSize / 2` ou documentar margem. |
| `GameState` hardcoded para 5 | Quebra níveis maiores | Refatorar primeiro. |
| `VictoryOverlay` hardcoded para sequência de 2 a 10 | Informação errada | Ler `levelData.sequence`. |
| Plataformas com bobbing mudam alcançabilidade | Pode dificultar saltos | Gerar com margem extra de 8px vertical. |
| Plataforma width variável sem ajustar colisão | Bugs | Usar `platform.width` real na colisão. |

## 15.4 Ordem Recomendada

1. Modelos de nível.
2. `GameState` dinâmico.
3. `SkipperGame` recebe `LevelData`.
4. Spawners.
5. LevelGenerator.
6. LevelSelectScreen.
7. ProgressManager/SaveManager.
8. Overlays atualizados.
9. Testes de geração.

---

# 16. Arquitetura Recomendada

## 16.1 `LevelDefinition`

Responsabilidade:

- Descrever intenção do nível antes da geração.
- Não contém posições finais.

Campos sugeridos:

```dart
class LevelDefinition {
  final int id;
  final String title;
  final int skipStep;
  final int startValue;
  final int correctCount;
  final int platformCount;
  final int distractorCount;
  final DifficultyRules difficulty;
}
```

## 16.2 `LevelGenerator`

Responsabilidade:

- Converter `LevelDefinition` em `GeneratedLevelData`.
- Garantir alcançabilidade.
- Gerar plataformas, estrelas e números.
- Aceitar seed.

## 16.3 `PlatformSpawner`

Responsabilidade:

- Receber `PlatformData`.
- Criar `PlatformComponent`.
- Adicionar ao `world`.
- Aplicar índice e largura variável.

## 16.4 `StarSpawner`

Responsabilidade:

- Receber `NumberData` ou `StarData`.
- Criar `StarComponent`.
- Centralizar estrela sobre plataforma correspondente.
- Adicionar ao `world`.

## 16.5 `DifficultyManager`

Responsabilidade:

- Dado o número do nível, retornar `DifficultyRules`.
- Controlar gaps máximos, quantidade de distratores, plataforma count, variação vertical.

Exemplo:

```dart
class DifficultyRules {
  final double minGapX;
  final double maxGapX;
  final double maxClimbY;
  final double maxDropY;
  final int maxGenerationAttempts;
}
```

## 16.6 `ProgressManager`

Responsabilidade:

- Saber quais níveis estão bloqueados/desbloqueados.
- Marcar conclusão.
- Consultar melhor tempo.
- Expor dados para `LevelSelectScreen`.

## 16.7 `SaveManager`

Responsabilidade:

- Persistir progresso via `SharedPreferences`.
- Centralizar chaves.
- Evitar lógica de save espalhada em overlays.

## 16.8 `LevelSelectScreen`

Responsabilidade:

- Exibir níveis em estilo SNES.
- Mostrar estado bloqueado/concluído.
- Gerar `LevelData` ao iniciar nível.
- Navegar para `GameScreen(levelData)`.

---

# 17. Dados para IA Externa

## 17.1 Resumo Completo da Mecânica

Skipper é um jogo educativo 2D de plataforma em Flutter + Flame. O jogador controla um personagem que pula entre plataformas e coleta estrelas numeradas. O objetivo educacional é ensinar skip counting: contar de 2 em 2, 3 em 3, 5 em 5, 10 em 10 etc.

No estado atual, há um único nível com sequência fixa `[2, 4, 6, 8, 10]`. O jogador deve coletar as estrelas na ordem correta. Coletar número errado causa perda de HP. Coletar todos os números corretos vence o nível.

## 17.2 Física do Jogador

Valores reais atuais:

- Resolução lógica: `800x450`.
- HUD/topbar: `25px`.
- Chão sólido conceitual: `800x80`, topo em `Y=370`.
- Player: `25x44`.
- Hitbox: `(4,4,17,36)`.
- Spawn atual: `(36,326)`, base no topo do chão (`326 + 44 = 370`).
- Gravidade normal: `1980 px/s²`.
- Gravidade segurando pulo: `900 px/s²`.
- Velocidade do pulo: `-570 px/s`.
- Velocidade horizontal: `180 px/s`.
- Terminal velocity: `720 px/s`.
- Jump cut multiplier: `0.4`.
- Coyote time: `0.1s`.

Alcance teórico:

- Altura full jump: `180.5px`.
- Distância horizontal full jump para mesma altura: `190.8px`.
- Limites seguros recomendados: `maxGapX=130`, `maxClimbY=80`, `maxDropY=60`.

## 17.3 Regras dos Níveis

Estado atual:

- 5 plataformas hardcoded.
- 5 estrelas hardcoded por derivação das plataformas.
- Sequência `[2,4,6,8,10]` hardcoded.
- Sem distratores.
- Vitória após coletar 5 estrelas na ordem.

Futuro desejado:

- Plataformas geradas proceduralmente.
- Estrelas centralizadas proceduralmente.
- Números corretos e distratores.
- Sequências progressivas.
- Tela de seleção.
- Salvamento de progresso.
- Garantia matemática de completabilidade.

## 17.4 HUD

HUD atual:

- Retângulo superior `800x25`.
- 3 corações em `(16,3)`, `(44,3)`, `(72,3)`.
- Pause visual em `(764,3)`, área touch `(746..794, 2..50)`.
- Texto de progresso centralizado em `x=400`, `y=7`, font `PressStart2P`, `12px`.
- Timer removido do HUD, mas ainda existe internamente e aparece na vitória.

## 17.5 Sistema de Progressão

Atual:

- Não há seleção de níveis.
- Não há desbloqueio de níveis.
- Ranking salva melhores tempos globais em `skipper_best_times`.
- Tutorial salva `hasSeenTutorial`.

Recomendado:

- `ProgressManager` + `SaveManager`.
- Chaves por nível.
- Níveis bloqueados/concluídos.
- Melhor tempo por nível.

## 17.6 Assets Utilizados

Imagens:

- `assets/images/background.png`
- `assets/images/objects/plataform.png`
- `assets/images/objects/star.png`
- `assets/images/player/idle.png`
- `assets/images/player/walk.png`
- `assets/images/player/jump.png`
- `assets/images/hud/btn_arrow_left.png`
- `assets/images/hud/btn_arrow_right.png`
- `assets/images/hud/btn_jump.png`
- `assets/images/hud/btn_interact.png`
- `assets/images/hud/heart_full.png`
- `assets/images/hud/heart_empty.png`
- `assets/images/hud/pause_icon.png`

Áudio registrado mas ainda não integrado no código atual:

- `assets/audio/music/bgm.mp3`
- `assets/audio/sfx/jump.mp3`
- `assets/audio/sfx/collect_correct.mp3`
- `assets/audio/sfx/collect_wrong.mp3`
- `assets/audio/sfx/game_over.mp3`
- `assets/audio/sfx/level_complete.mp3`

Fonte:

- `assets/fonts/pixel_font.ttf`
- Registrada como `PixelFont`.

Tiles:

- `assets/tiles/map.tmx`
- `assets/tiles/plataform.tmx`
- Registrados mas não usados no runtime atual.

## 17.7 Limitações Atuais

- Apenas um nível real.
- Layout hardcoded.
- `GameState.starsCollected` hardcoded para 5.
- Sequência correta hardcoded em `game_config.dart`.
- `VictoryOverlay` hardcoded para mostrar `2 - 4 - 6 - 8 - 10`.
- `LevelData` existe mas não é usado.
- Não há distratores.
- Não há geração procedural.
- Não há tela de seleção.
- Não há progresso por nível.
- `PlatformComponent` não suporta largura variável.
- `starInteractionRadius = 22` é grande para estrela 25x25.
- Não há testes automatizados para física/geração.

## 17.8 Problemas Conhecidos

- Sistema atual não escala para mais de 5 estrelas sem refatorar `GameState`.
- `SkipperGame` mistura responsabilidades de geração, spawn, controle de estado e save.
- `VictoryOverlay` salva ranking global, não por nível.
- O tempo ainda roda internamente mesmo não aparecendo no HUD.
- Plataforma boba verticalmente, então a geração procedural deve considerar margem extra.
- Estrela boba verticalmente, então validação de overlap deve considerar `±4px`.

## 17.9 Melhorias Planejadas

- `LevelDefinition` para configurar níveis.
- `LevelGenerator` para gerar posições e números.
- `PlatformSpawner` e `StarSpawner` para desacoplar spawn.
- `DifficultyManager` para regras progressivas.
- `ProgressManager` para desbloqueios.
- `SaveManager` para persistência.
- `LevelSelectScreen` estilo SNES.
- Testes automatizados de 1000 seeds por nível.
- Distratores educacionais.
- Suporte futuro a dezenas/centenas de níveis sem hardcoding.

## 17.10 Objetivo Final de Implementação

Permitir:

- Plataformas geradas proceduralmente.
- Estrelas posicionadas proceduralmente.
- Números sempre em posições diferentes.
- Níveis progressivamente mais difíceis.
- Tela de seleção de níveis estilo SNES.
- Salvamento de progresso.
- Garantia matemática de que nenhum nível seja impossível.
- Expansão para dezenas ou centenas de níveis sem posições hardcoded.
