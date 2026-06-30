# SKIPPER — Documento de Planejamento

**Versão:** 3.0
**Data:** 23/06/2026
**Revisão:** Correções técnicas após análise cruzada de dois revisores especializados em Flutter + Flame
**Autor:** Planejamento gerado com assistência de IA

---

## Sumário

1. [Visão Geral do Jogo](#1-visão-geral-do-jogo)
2. [Stack Tecnológica e Arquitetura](#2-stack-tecnológica-e-arquitetura)
3. [Resolução e Padronização de Assets](#3-resolução-e-padronização-de-assets)
4. [Paleta de Cores](#4-paleta-de-cores)
5. [Layout da Tela do Jogo](#5-layout-da-tela-do-jogo)
6. [Text Styling — Todos os Textos do Jogo](#6-text-styling--todos-os-textos-do-jogo)
7. [Tela de Pausa](#7-tela-de-pausa)
8. [Tela de Vitória](#8-tela-de-vitória)
9. [Tela de Game Over](#9-tela-de-game-over)
10. [Física e Input](#10-física-e-input)
11. [Lógica e Regras do Jogo](#11-lógica-e-regras-do-jogo)
12. [Estrutura de Dados](#12-estrutura-de-dados-conceitual)
13. [Animações e Efeitos](#13-animações-e-efeitos)
14. [Recomendações de Recursos Gratuitos](#14-recomendações-de-recursos-gratuitos)
15. [Implementação no Flutter / Flame](#15-implementação-no-flutter--flame)
16. [Estrutura de Arquivos](#16-estrutura-de-arquivos)
17. [Tabela Mestra de Posicionamentos](#17-tabela-mestra-de-posicionamentos)
18. [Tutorial — Primeira Execução](#18-tutorial--primeira-execução)
19. [Timer e Ranking Local](#19-timer-e-ranking-local)
20. [Acessibilidade](#20-acessibilidade)

---

## 1. Visão Geral do Jogo

| Campo | Valor |
|---|---|
| **Título** | Skipper |
| **Gênero** | Plataforma educativo 2D (single-screen) |
| **Estilo visual** | 16-bit suave (SNES-inspired, paleta pastel/soft) |
| **Engine** | Flame ^1.14.0 (sobre Flutter 3.x) |
| **Plataformas alvo** | Android (mobile) + Web (navegador) |
| **Orientação** | Paisagem (landscape) fixa |
| **Público-alvo** | 10–15 anos |
| **Conceito ensinado** | Skip counting (contar de 2 em 2 até 10) |
| **Nível atual** | 1 fase |
| **Tela única** | Sim — sem scroll ou camera movement |

### Objetivo do Jogo

O jogador controla um personagem que precisa coletar estrelas numeradas **(2, 4, 6, 8, 10) na ordem crescente**, pulando entre plataformas. Cada estrela coletada corretamente preenche o mapa de progresso no topo. Errar a ordem custa 1 coração de vida. O objetivo é coletar todas as 5 estrelas antes de perder os 3 corações.

### Público-Alvo

| Aspecto | Detalhe |
|---|---|
| **Faixa etária** | 10–15 anos |
| **Escolaridade** | Ensino Fundamental II |
| **Habilidade trabalhada** | Skip counting (base para multiplicação) |
| **Estilo de jogo** | Casual, sem violência, ritmo próprio |

---

## 2. Stack Tecnológica e Arquitetura

### Tecnologias Escolhidas

| Camada | Tecnologia | Motivo |
|---|---|---|
| **Framework** | Flutter 3.x | Código único para Android + Web. Performance nativa. Suporte touch + teclado + áudio + fontes. |
| **Engine 2D** | Flame ^1.14.0 (fixo no `pubspec.yaml`) | Madura para Flutter. Fornece `FlameGame`, `CameraComponent`, `CollisionCallbacks`, sprites, áudio, input. |
| **Gerenciamento de estado** | `ChangeNotifier` + `GameState` | Simples o suficiente para um jogo single-screen. `GameState` estende `ChangeNotifier` e dispara `notifyListeners()` nos pontos de mutação para integração com a UI Flutter. |

### Decisão de Arquitetura: Virtual Resolution

**Problema:** Dispositivos têm resoluções muito variadas (ex: iPhone SE 1334×750, Galaxy S24 2340×1080, iPad 2360×1640, desktop 1920×1080). O jogo precisa aparecer IDÊNTICO em todos.

**Solução:** Usar `CameraComponent.withFixedResolution(800, 450)` no Flame. Isso define um espaço de jogo virtual de **800×450 pixels** (16:9). A câmera renderiza esse espaço e escala para caber na tela real, mantendo proporção. Assets, posições e lógica usam coordenadas virtuais. Flame faz a conversão para pixels reais automaticamente.

**Vantagens deste approach sobre alternativas:**

| Abordagem | Vantagens | Desvantagens |
|---|---|---|
| **Virtual Resolution (escolhida)** | Único conjunto de assets; layout idêntico em qualquer tela; letterbox automático | Pequenas barras pretas em aspect ratios não-16:9 |
| **Responsivo (cálculo por %)** | Flexível em qualquer aspect ratio | Mais complexo; chance de layout quebrar; mais testes |
| **Múltiplos assets por resolução** | Pixel-perfect em cada dispositivo | Muitos assets para gerenciar; pesado para manter |

**Comportamento do background em telas diferentes:**
- O background NÃO é uma imagem única — é composto de:
  - **Céu**: gradiente vertical procedural (80 colunas com interpolação entre duas cores)
  - **Nuvens**: sprites ou formas geométricas em posições virtuais fixas
  - **Colinas**: arcos/elipses desenhados com `Canvas.drawArc`
- Como tudo é definido em coordenadas virtuais 800×450, o resultado visual é **idêntico em qualquer resolução**

---

## 3. Resolução e Padronização de Assets

### Resolução Virtual

| Propriedade | Valor |
|---|---|
| **Resolução virtual (jogo)** | 800 × 450 px |
| **Proporção** | 16:9 |
| **Viewport** | `CameraComponent.withFixedResolution(800, 450)` |
| **Método de escala** | `ImageInterpolation.near` (pixel-art) |

### Padronização de Tamanho de Assets

| Tipo de Asset | Tamanho ideal | Renderiza em | Como usar no Flame |
|---|---|---|---|
| **Background (se imagem)** | 800×450 px | 800×450 | `SpriteComponent(size: Vector2(800, 450))` |
| **Botões (setas, pulo, interagir)** | 64×64 px | 56×56 / 60×60 | `SpriteComponent(size: Vector2(56, 56))` |
| **Coração (full / empty)** | 32×32 px | 32×32 | `SpriteComponent(size: Vector2(32, 32))` |
| **Estrela** | 48×48 px | 40×40 | `SpriteComponent(size: Vector2(40, 40))` |
| **Botão de pausa** | 32×32 px | 32×32 | `SpriteComponent(size: Vector2(32, 32))` — asset: `pause_icon.png` |
| **Nuvem** | 64×32 px | 64×32 | `SpriteComponent(size: Vector2(64, 32))` |
| **Player (spritesheet)** | 24×30 px por frame | 24×30 | `SpriteAnimationComponent(size: Vector2(24, 30))` |
| **Partículas** | 8×8 px cada | 8×8 | Gerado proceduralmente |

**Regra importante:** O tamanho do PNG original é irrelevante para o Flame — o que importa é o `size` definido no componente. Flame faz o scale automático. Portanto, você pode criar assets em qualquer resolução (ex: 283×283 dos corações atuais) e definir `size: Vector2(32, 32)` para renderizar em 32×32.

### Exemplo de carregamento com redimensionamento

```dart
final heartSprite = await Sprite.load('hud/heart_full.png');
final component = SpriteComponent(
  sprite: heartSprite,
  size: Vector2(32, 32),     // tamanho em coordenadas virtuais
  position: Vector2(16, 10), // posição na tela virtual
);
```

---

## 4. Paleta de Cores

Todas as cores foram escolhidas para serem **suaves e agradáveis** — nenhum HEX primário puro. Cores funcionam em mobile sem causar fadiga visual.

| Contexto | Nome | HEX | RGB | Uso |
|---|---|---|---|---|
| **Céu topo** | Soft Sky Blue | `#87CEEB` | rgb(135,206,235) | Gradiente superior do fundo |
| **Céu base** | Powder Blue | `#B0E0E6` | rgb(176,224,230) | Gradiente inferior do fundo |
| **Nuvem** | Floral White | `#FFFAFA` | rgb(255,250,250) | Nuvens (opacidade 75%) |
| **Colina fundo** | Pale Green | `#98FB98` | rgb(152,251,152) | Colina distante |
| **Colina frente** | Light Green | `#90EE90` | rgb(144,238,144) | Colina próxima |
| **Grama (chão)** | Olive Drab | `#6B8E23` | rgb(107,142,35) | Topo do chão |
| **Terra (chão)** | Burlywood | `#DEB887` | rgb(222,184,135) | Corpo do chão |
| **Sombra (chão)** | Tan | `#D2B48C` | rgb(210,180,140) | Base do chão |
| **Plataforma corpo** | Peru | `#CD853F` | rgb(205,133,63) | Corpo da plataforma |
| **Plataforma destaque** | Burlywood | `#DEB887` | rgb(222,184,135) | Borda superior (2px) |
| **Plataforma sombra** | Dark Sienna | `#8B7355` | rgb(139,115,85) | Borda inferior (2px) |
| **Player corpo** | Indian Red | `#CD5C5C` | rgb(205,92,92) | Personagem |
| **Player pele** | Moccasin | `#FFE4B5` | rgb(255,228,181) | Rosto/mãos |
| **Player sapato** | Saddle Brown | `#8B4513` | rgb(139,69,19) | Sapatos |
| **Estrela** | Gold | `#FFD700` | rgb(255,215,0) | Estrela coletável |
| **Brilho estrela** | Cornsilk | `#FFF8DC` | rgb(255,248,220) | Glow (30% opacidade) |
| **Número na estrela** | White | `#FFFFFF` | rgb(255,255,255) | Texto sobre estrela |
| **Contorno número** | Saddle Brown | `#8B4513` | rgb(139,69,19) | Stroke do texto |
| **HUD fundo** | Dark Charcoal | `#2F2F2F` | rgb(47,47,47) | Barra HUD (75% opacidade) |
| **Borda HUD** | Gray 50% | `#808080` | rgb(128,128,128) | Borda inferior 2px |
| **Coração cheio** | Soft Red | `#FF6B6B` | rgb(255,107,107) | Coração cheio |
| **Coração vazio** | Gray Silver | `#C0C0C0` | rgb(192,192,192) | Coração vazio |
| **Texto coletado** | Gold | `#FFD700` | rgb(255,215,0) | Número coletado |
| **Texto pendente** | Soft Gray | `#9E9E9E` | rgb(158,158,158) | Número não coletado |
| **Feedback acerto** | Soft Green | `#81C784` | rgb(129,199,132) | Efeito de coleta correta |
| **Feedback erro** | Soft Red | `#E57373` | rgb(229,115,115) | Efeito de coleta errada |
| **Fundo overlay pausa** | Dark Overlay | `rgba(0,0,0,0.6)` | — | Overlay de pausa |
| **Ícone pause** | Light Gray | `#E0E0E0` | rgb(224,224,224) | Botão de pausa |
| **Botões touch fundo** | Transparente | `rgba(0,0,0,0.2)` | — | Círculo atrás dos botões |
| **Fundo vitória** | Soft Gold gradient | `#FFF8DC`→`#FFE4B5` | — | Gradiente da vitória |
| **Fundo game over** | Soft Red gradient | `#FFD0D0`→`#FFB0B0` | — | Gradiente do game over |

---

## 5. Layout da Tela do Jogo

### Divisão Vertical da Tela

```
 800 × 450 px (virtual)

  ┌────────────────────────────────────────────────────────────────┐
 │  HUD (y=0 a y=48) — [♥][♥][♥]  [2] - [4] - 6 - 8 - 10  ⏸  00:00│
 ├────────────────────────────────────────────────────────────────┤
 │                                                                │
 │                     ★ (6)                                      │
 │            ┌─────────┴─────────┐     y=220 (P3)               │
 │            │   Plataforma 3    │                               │
 │            └───────────────────┘                               │
 │      ★ (4)                         ★ (8)                      │
 │   ┌───┴───┐                   ┌───┴───┐   y=280 (P2,P4)      │
 │   │  P2   │                   │  P4   │                       │
 │   └───────┘                   └───────┘                       │
 │  ★ (2)                                            ★ (10)     │
 │ ┌─┴───┐                                            ┌──┴──┐    │
 │ │ P1  │          ÁREA DE JOGO                      │ P5  │    │
 │ └─────┘                         y=340 (P1,P5)      └─────┘    │
 │                                                                │
 │  [◀] [▶]        y=342-450                              [⬆][✋] │
 ├────────────────────────────────────────────────────────────────┤
 │  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
 │  ▓▓▓▓▓▓▓▓ GROUND (y=390-450) ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
 │  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
 └────────────────────────────────────────────────────────────────┘
```

### Top HUD (y=0 a y=48)

**Fundo:**
- Retângulo `(0, 0, 800, 48)` — cor `#2F2F2F` com opacidade 75%
- Borda inferior: 2px sólida `#808080`

| Elemento | Asset / Ícone | X | Y | Largura | Altura | Comportamento |
|---|---|---|---|---|---|---|
| **Coração 1** | `heart_full.png` ou `heart_empty.png` | 16 | 10 | 32 | 32 | Troca sprite conforme HP |
| **Coração 2** | `heart_full.png` ou `heart_empty.png` | 54 | 10 | 32 | 32 | Espaçamento de 6px entre eles |
| **Coração 3** | `heart_full.png` ou `heart_empty.png` | 92 | 10 | 32 | 32 | — |
| **Progresso (texto)** | Renderizado em tela | 240 | 14 | 320 | 28 | Ver seção de Text Styling |
| **Timer** | Renderizado em tela | 640 | 14 | 80 | 28 | "00:00", Press Start 2P 14px, cor `#E0E0E0` |
| **Botão Pausa** | `pause_icon.png` | 758 | 10 | 32 | 32 | Sprite 32×32, hitbox (746, 2, 48, 48) |

 

### Background (y=48 a y=390)

**Céu (gradiente procedural):**
- Retângulo: `(0, 48, 800, 252)` — 342px de altura (do topo da área de jogo até o chão)
- Gradiente vertical: topo `#87CEEB` → base `#B0E0E6`
- Implementação: `Canvas.drawRect` com `LinearGradient`

**Nuvens (decorativas, placeholders coloridos):**

| Nuvem | Posição (X, Y) | Dimensões | Cor |
|---|---|---|---|
| Nuvem 1 | (100, 85) | ~60×24 (3 círculos: raios 6, 10, 6) | `#FFFAFA` @ 75% |
| Nuvem 2 | (350, 70) | ~72×26 (3 círculos: raios 7, 11, 7) | `#FFFAFA` @ 70% |
| Nuvem 3 | (580, 90) | ~56×22 (3 círculos: raios 5, 9, 5) | `#FFFAFA` @ 75% |

**Colinas (decorativas, fundo parallax fixo):**

| Colina | Cor | Forma | Dimensões |
|---|---|---|---|
| Colina 1 (fundo) | `#98FB98` | Arco (meia-elipse), centrado em X=400 | ~800 de largura, ~60px de altura, topo em y=280 |
| Colina 2 (frente) | `#90EE90` | Arco (meia-elipse), centrado em X=200 | ~800 de largura, ~50px de altura, topo em y=300 |

### Plataformas

**Estilização:**
- Corpo (preenchimento): `#CD853F`
- Borda superior (2px): `#DEB887` — simula luz do topo
- Borda inferior (2px): `#8B7355` — simula sombra
- Cantos arredondados: `RRect` com `radius = 3`

| Plataforma | Nº | X | Y | Largura | Altura |
|---|---|---|---|---|---|
| P1 | 2 | 60 | 340 | 120 | 16 |
| P2 | 4 | 200 | 280 | 120 | 16 |
| P3 | 6 | 340 | 220 | 120 | 16 |
| P4 | 8 | 480 | 280 | 120 | 16 |
| P5 | 10 | 600 | 340 | 120 | 16 |

**Gaps entre plataformas:**

| Trajeto | ΔX | ΔY | Sentido |
|---|---|---|---|
| P1 → P2 | +140 px | −60 px | Sobe |
| P2 → P3 | +140 px | −60 px | Sobe |
| P3 → P4 | +140 px | +60 px | Desce |
| P4 → P5 | +120 px | +60 px | Desce |

### Estrelas (sobre as plataformas)

**Estilização:**
- Asset: `star.png` redimensionado para **40×40 px**
- Glow: círculo `#FFF8DC` com 30% de opacidade, dimensões 50×50, centralizado atrás da estrela
- Número centralizado sobre a estrela

**Cálculo de posição:**
```
star.x = platform.x + (platform.w - star.w) / 2
star.y = platform.y - star.h
```

| Estrela | Nº | Plataforma | X | Y | Largura | Altura |
|---|---|---|---|---|---|---|
| S1 | 2 | P1 | 100 | 300 | 40 | 40 |
| S2 | 4 | P2 | 240 | 240 | 40 | 40 |
| S3 | 6 | P3 | 380 | 180 | 40 | 40 |
| S4 | 8 | P4 | 520 | 240 | 40 | 40 |
| S5 | 10 | P5 | 640 | 300 | 40 | 40 |

**Hitbox de interação:** `(star.x - 8, star.y - 8, 56, 56)` — buffer de 8px para facilitar o toque.
**Distância centro-a-centro para interação:** 44 pixels.

### Player

**Estilização (placeholder até termos spritesheet):**

| Parte | Posição (relativa ao player) | Dimensões | Cor |
|---|---|---|---|
| Container total | (0, 0) | 24 × 30 | — |
| Rosto/pele | (8, 2) | 8 × 8 | `#FFE4B5` |
| Olho | (11, 4) | 2 × 2 | `#2F2F2F` |
| Corpo | (2, 10) | 20 × 14 | `#CD5C5C` |
| Sapatos | (0, 26) | 24 × 4 | `#8B4513` |

**Posição inicial:** Sobre a Plataforma 1 (P1).
```
player.x = 108  (centralizado em P1: 60 + (120 - 24) / 2)
player.y = 310  (P1.y - player.h = 340 - 30)
```

**Hitbox de colisão:** `(player.x + 2, player.y + 2, 20, 28)` — 2px de margem em cada lado e no topo.

### Chão

| Camada | Y | Altura | Cor |
|---|---|---|---|
| Grama (topo) | 390 | 12 px | `#6B8E23` |
| Terra (meio) | 402 | 34 px | `#DEB887` |
| Sombra (base) | 436 | 14 px | `#D2B48C` |

**Colisão:** Retângulo `(0, 390, 800, 60)` — superfície sólida em y=390.

### Touch Controls (overlay)

Sempre sobrepostos, não afetados pela câmera. Renderizados em uma camada HUD separada.

| Botão | Função | Asset | X | Y | Largura | Altura | Hitbox de toque |
|---|---|---|---|---|---|---|---|
| **←** | Mover esquerda | `btn_arrow_left.png` | 20 | 378 | 56 | 56 | (16, 370, 62, 72) |
| **→** | Mover direita | `btn_arrow_right.png` | 84 | 378 | 56 | 56 | (82, 370, 62, 72) |
| **⬆** | Pular | `btn_jump.png` | 636 | 370 | 60 | 60 | (628, 360, 70, 80) |
| **✋** | Interagir | `btn_interact.png` | 710 | 370 | 60 | 60 | (704, 360, 70, 80) |

**Estilização dos botões:**
- Fundo circular atrás de cada botão: círculo `rgba(0,0,0,0.2)` com raio de 34px
- Opacidade do asset: 85%
- Efeito de pressionado: escala 0.9 + opacidade 60% (animação de 0.1s)

---

## 6. Text Styling — Todos os Textos do Jogo

### 6.1 Fonte Padrão

| Propriedade | Valor |
|---|---|
| **Fonte primária** | Press Start 2P (Google Fonts) |
| **Categoria** | Pixel bitmapped, monoespaçada |
| **Licença** | SIL Open Font License 1.1 |
| **Fallback** | `'Courier New', monospace` |
| **Inclusão no Flutter** | Via `google_fonts` package ou .ttf em `assets/fonts/` |
| **Renderização** | A Press Start 2P possui glifos desenhados em blocos quadrados, que produzem aparência pixelada natural mesmo com a suavização padrão do motor de renderização de texto (Skia/Impeller). Não é necessário — nem simples — desligar o anti-aliasing de fontes TTF. Para um efeito 100% pixel-perfect (futuro), migrar para `SpriteFontRenderer` com bitmap font. |

### 6.2 Texto do Progresso (HUD)

| Propriedade | Valor |
|---|---|
| **Conteúdo** | `[2]  -  [4]  -  6  -  8  -  10` |
| **Container** | (240, 14, 320, 28) |
| **Alinhamento horizontal** | Centralizado no container (`TextAlign.center`) |
| **Alinhamento vertical** | Centralizado (`Anchor.center`) |
| **Fonte** | Press Start 2P, 14px |

**Estilização por parte do texto:**

| Parte | Cor | Efeito |
|---|---|---|
| Colchetes `[` `]` de itens coletados | `#FFD700` | Sombra: `rgba(0,0,0,0.3)` 1px |
| Números coletados (2, 4) | `#FFD700` | Sombra: `rgba(0,0,0,0.3)` 1px |
| Números pendentes (6, 8, 10) | `#9E9E9E` | — |
| Separadores `-` | `#666666` | — |

**Espaçamento:**
- Entre blocos `[N]`: 12px
- Entre `[N]` e `-`: 6px
- Entre `-` e próximo `[N]`: 6px

### 6.3 Número na Estrela

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "2", "4", "6", "8", "10" |
| **Posição** | Centralizado na estrela |
| **Fonte** | Press Start 2P, 16px |
| **Cor** | `#FFFFFF` |
| **Contorno (stroke)** | `#8B4513`, largura 2px |
| **Sombra** | `rgba(0,0,0,0.4)`, offset (1,1), blur 1 |

### 6.4 Botão Pausa (sprite)

Substitui o ícone Unicode. Consistente com o restante do HUD que já utiliza sprites.

| Propriedade | Valor |
|---|---|
| **Asset** | `pause_icon.png` |
| **Posição** | (758, 10) |
| **Dimensões** | 32×32 px |
| **Opacidade** | 85% |

### 6.5 Texto do Timer (HUD)

| Propriedade | Valor |
|---|---|
| **Conteúdo** | `"00:00"` → atualizado em tempo real (`MM:SS`) |
| **Posição** | (640, 14), container 80×28 |
| **Fonte** | Press Start 2P, 14px |
| **Cor** | `#E0E0E0` |
| **Alinhamento** | Centralizado no container |
| **Início** | Começa em `00:00` no load, para na vitória, reseta no restart |

### 6.6 Texto de Feedback Pedagógico ("Próxima estrela: N")

Exibido brevemente após um erro de ordem, reforçando o aprendizado.

| Propriedade | Valor |
|---|---|
| **Conteúdo** | `"Próxima estrela: N"` (ex: "Próxima estrela: 4") |
| **Posição** | Centralizado horizontalmente, Y = player.y − 40 |
| **Fonte** | Pixelify Sans, 14px |
| **Cor** | `#FFD700` |
| **Contorno (stroke)** | `rgba(0,0,0,0.6)`, largura 2px |
| **Alinhamento** | Centralizado |
| **Duração** | 1.5 segundos, com fade-out nos últimos 0.3s |
| **Gatilho** | Exibido quando o jogador tenta coletar uma estrela na ordem errada |

### 6.7 Texto de Feedback de Acerto/Erro (ícones ✓/✗)

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "✓" (acerto) ou "✗" (erro) |
| **Posição** | Centralizado acima do player, Y = player.y − 42 |
| **Fonte** | Sans-serif (glifo simples), tamanho 20px |
| **Cor acerto** | `#81C784` (Soft Green) |
| **Cor erro** | `#E57373` (Soft Red) |
| **Duração** | 0.5s, com fade-out |
| **Gatilho** | Exibido após cada tentativa de coleta (acerto ou erro) |

### 6.8 Letter-Spacing

---

## 7. Tela de Pausa

**Implementação:** Flutter overlay via `GameWidget.overlayBuilderMap`, com layout responsivo usando `Center`, `Column` e `SizedBox` — sem coordenadas absolutas. Posicionamento adapta-se automaticamente a qualquer tamanho de tela real.

### Fundo

| Propriedade | Valor |
|---|---|
| **Forma** | Retângulo 800×450 |
| **Cor** | `rgba(0, 0, 0, 0.6)` |
| **Z-index** | Acima de tudo (layer 999) |

### Título "PAUSADO"

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "PAUSADO" |
| **Posição** | X=400, Y=180 |
| **Fonte** | Press Start 2P, 32px |
| **Cor** | `#FFFFFF` |
| **Alinhamento** | Centralizado (`Anchor.center`) |
| **Sombra** | `rgba(0,0,0,0.5)`, offset (2,2), blur 3 |
| **Letter spacing** | `TextStyle(letterSpacing: 4.0)` — suportado nativamente pelo Flutter |

### Botão "CONTINUAR"

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "CONTINUAR" |
| **Posição** | X=400, Y=260 |
| **Fonte** | Pixelify Sans, 18px |
| **Cor** | `#81C784` |
| **Fundo do botão** | `rgba(255,255,255,0.1)`, borda `rgba(255,255,255,0.3)` 2px |
| **Dimensões do botão** | 220 × 50 px |
| **Raio de borda** | 8 px |
| **Alinhamento** | Centralizado no botão |
| **Ação** | `onTap`: retoma o jogo |

---

## 8. Tela de Vitória

**Implementação:** Flutter overlay via `GameWidget.overlayBuilderMap`, com layout responsivo usando `Center`, `Column` e `SizedBox`.

### Fundo

| Propriedade | Valor |
|---|---|
| **Gradiente** | `#FFF8DC` (cornsilk) → `#FFE4B5` (moccasin) |
| **Dimensões** | 800 × 450 px |

### Título "VITÓRIA!"

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "VITÓRIA!" |
| **Posição** | X=400, Y=150 |
| **Fonte** | Press Start 2P, 36px |
| **Cor** | `#FFD700` |
| **Alinhamento** | Centralizado |
| **Sombra** | `rgba(0,0,0,0.3)`, offset (2,2), blur 4 |

### Subtexto "VOCÊ COLETOU TODAS AS ESTRELAS!"

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "VOCÊ COLETOU TODAS AS ESTRELAS!" |
| **Posição** | X=400, Y=200 |
| **Fonte** | Pixelify Sans, 12px |
| **Cor** | `#8B7355` |
| **Alinhamento** | Centralizado |

### Lista de Números Coletados

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "2  -  4  -  6  -  8  -  10" |
| **Posição** | X=400, Y=230 |
| **Fonte** | Press Start 2P, 16px |
| **Cor** | `#CD853F` |
| **Alinhamento** | Centralizado |

### Tempo de Conclusão

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "Seu tempo: 00:32" |
| **Posição** | X=400, Y=265 |
| **Fonte** | Press Start 2P, 14px |
| **Cor** | `#CD853F` |
| **Alinhamento** | Centralizado |

### Ranking Local (3 melhores tempos)

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "🥇 00:25" / "🥈 00:30" / "🥉 00:32" |
| **Posição** | X=400, Y=295 |
| **Fonte** | Pixelify Sans, 12px |
| **Cor** | `#8B4513` |
| **Alinhamento** | Centralizado |
| **Persistência** | Salvo via `shared_preferences`, chave `skipper_best_times` |

### Botão "JOGAR NOVAMENTE"

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "JOGAR NOVAMENTE" |
| **Posição** | X=400, Y=350 |
| **Fonte** | Pixelify Sans, 16px |
| **Cor** | `#81C784` |
| **Fundo** | `rgba(0,0,0,0.08)`, borda `rgba(0,0,0,0.15)` 2px |
| **Dimensões** | 260 × 50 px |
| **Raio** | 8 px |
| **Alinhamento** | Centralizado |
| **Ação** | Reinicia o jogo |

### Efeitos Visuais
- 5 estrelas decorativas girando/brilhando ao redor do título (animação scale 1.0→1.1→1.0, loop 1.5s)
- Partículas douradas subindo (opcional)

---

## 9. Tela de Game Over

**Implementação:** Flutter overlay via `GameWidget.overlayBuilderMap`, com layout responsivo usando `Center`, `Column` e `SizedBox`.

### Fundo

| Propriedade | Valor |
|---|---|
| **Gradiente** | `#FFD0D0` → `#FFB0B0` |
| **Dimensões** | 800 × 450 px |

### Título "FIM DE JOGO"

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "FIM DE JOGO" |
| **Posição** | X=400, Y=170 |
| **Fonte** | Press Start 2P, 32px |
| **Cor** | `#E57373` |
| **Alinhamento** | Centralizado |
| **Sombra** | `rgba(0,0,0,0.3)`, offset (2,2), blur 4 |

### Subtexto "VOCÊ PERDEU TODOS OS CORAÇÕES"

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "VOCÊ PERDEU TODOS OS CORAÇÕES" |
| **Posição** | X=400, Y=215 |
| **Fonte** | Pixelify Sans, 12px |
| **Cor** | `#8B4513` |
| **Alinhamento** | Centralizado |

### Botão "TENTAR NOVAMENTE"

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "TENTAR NOVAMENTE" |
| **Posição** | X=400, Y=280 |
| **Fonte** | Press Start 2P, 18px |
| **Cor** | `#81C784` |
| **Fundo** | `rgba(255,255,255,0.15)`, borda `rgba(255,255,255,0.3)` 2px |
| **Dimensões** | 260 × 50 px |
| **Raio** | 8 px |
| **Alinhamento** | Centralizado |
| **Ação** | Reinicia a fase (HP=3, estrelas restauradas, player na P1) |

---

## 10. Física e Input

### Nota sobre Delta Time (`dt`)

**Toda a física deste documento foi convertida para ser independente de frame-rate.** Os valores são expressos em `px/s` e `px/s²` e multiplicados por `dt` (tempo desde o último frame, em segundos) a cada `update()`. Isso garante comportamento idêntico em dispositivos de 60Hz, 90Hz, 120Hz e Web com vsync variável.

A conversão foi feita assumindo 60fps como referência (`fator = 60` para velocidades, `fator = 60² = 3600` para acelerações).

### Parâmetros Físicos do Player

| Parâmetro | Símbolo | Valor (com `dt`) | Origem (px/frame @ 60fps) | Unidade |
|---|---|---|---|---|
| Gravidade normal | `g` | 1980 | 0.55 × 3600 | px/s² |
| Gravidade reduzida (hold) | `g_hold` | 900 | 0.25 × 3600 | px/s² |
| Velocidade inicial do pulo | `v0` | −570 | −9.5 × 60 | px/s |
| Velocidade horizontal | `vx` | 240 | 4.0 × 60 | px/s |
| Velocidade máxima de queda | `v_max_y` | 720 | 12.0 × 60 | px/s |
| Fricção (ao soltar tecla) | — | 0.85 | — | multiplicador/frame |

**Aplicação no `update(double dt)`:**
```dart
void update(double dt) {
  vy += gravity * dt;            // aceleração
  vy = vy.clamp(-double.infinity, vMaxY); // terminal velocity
  y  += vy * dt;                 // posição
  x  += vx * dt;
}
```

### Mecânica de Pulo Variável com Corte de `vy` (Opção A — Estilo Super Mario)

O jogador controla a altura do pulo cortando a velocidade vertical ao soltar o botão:

```
Estados do pulo:

1. BOTÃO DE PULO PRESSIONADO (estando no chão):
   → player.vy = -570
   → player.isJumping = true
   → player.isHoldingJump = true

2. ENQUANTO BOTÃO SEGURADO E player.vy < 0 (subindo):
   → gravity = g_hold (900) ← gravidade reduzida, sobe mais
   → Altura máxima ≈ 77px (~570² / (2×900) / 60 ≈ 77px)

3. BOTÃO SOLTO (enquanto ainda sobe):
   → player.vy *= 0.4  ← corta a velocidade para 40%
   → gravity = g (1980) ← gravidade normal, freia a subida rapidamente
   → Altura resultante ≈ 38px
   → player.isHoldingJump = false

4. BOTÃO SOLTO (já caindo) OU player.vy >= 0:
   → gravity = g (1980) ← gravidade normal
   → player.isHoldingJump = false

5. PLAYER TOCA O CHÃO / PLATAFORMA:
   → player.vy = 0
   → player.isJumping = false
   → player.isGrounded = true
   → _coyoteTimer = 0
```

**Resultado do controle de altura:**
- **Toque rápido no botão:** pulo baixo (~38px) — `vy` é cortado para 40% assim que o botão é solto
- **Segurar o botão até o topo:** pulo alto (~77px) — gravidade reduzida sustentada durante toda a subida
- **Controle natural e intuitivo:** o jogador aprende em segundos

### Coyote Time (Input Buffering no Pulo)

Permite pular até **100ms** após sair da borda de uma plataforma. Essencial para "jogabilidade justa" e recomendado para o público infantojuvenil.

```dart
double _coyoteTimer = 0.0;
const double coyoteThreshold = 0.1; // segundos

void update(double dt) {
  if (!isGrounded) {
    _coyoteTimer += dt;
  }
}

bool get canJump => isGrounded || _coyoteTimer < coyoteThreshold;
```

5 linhas de código que eliminam a frustração de "apertei o pulo mas já tinha caído da borda".

### Controle Aéreo
- O jogador pode mover para esquerda/direita **durante o pulo** (vx = ±240)
- **Não pode pular novamente** até tocar o chão ou uma plataforma (sem double jump)
- Pressionar pulo no ar: nenhum efeito

### Input Mobile (Touch)

| Interação | Ação | Evento |
|---|---|---|
| Pressionar ← | `player.vx = -240` | `onTapDown` |
| Soltar ← | `player.vx *= 0.85` (fricção) | `onTapUp` |
| Pressionar → | `player.vx = +240` | `onTapDown` |
| Soltar → | `player.vx *= 0.85` | `onTapUp` |
| Pressionar ⬆ | Inicia pulo (se canJump) | `onTapDown` |
| Segurar ⬆ | Mantém gravidade reduzida + `isHoldingJump = true` | estado held |
| Soltar ⬆ | Corta `vy *= 0.4` (se subindo) + restaura gravidade normal | `onTapUp` |
| Pressionar ✋ | Tenta interagir com estrela | `onTapDown` |

### Input Web (Teclado)

| Tecla | Ação | Equivalente Mobile |
|---|---|---|
| `←` ou `A` | Mover esquerda | ← |
| `→` ou `D` | Mover direita | → |
| `Espaço` / `↑` / `W` | Pular (com held para altura) | ⬆ |
| Soltar `espaço/↑/W` | Corta pulo (gravidade normal) | Soltar ⬆ |
| `E` ou `Enter` | Interagir | ✋ |
| `Escape` ou `P` | Pausar / Retomar | Botão pause |

### Limites da Tela (Player Não Sai da Tela)

A cada frame, após aplicar física:

```dart
player.x = player.x.clamp(2, 800 - player.width - 2);
player.y = player.y.clamp(48, 450 - player.height);
```

- Limite esquerdo: x ≥ 2
- Limite direito: x ≤ 800 - player.w - 2
- Limite superior: y ≥ 48 (abaixo da HUD)
- Limite inferior: y ≤ 450 (fora da tela = respawn)

Se `player.y > 380` inicia queda livre com respawn programado.

---

## 11. Lógica e Regras do Jogo

### Fluxo de Estados

```
[LOADING] → [PLAYING] ⇄ [PAUSED]
                ↓
           [VICTORY] → [PLAYING] (restart)
                ↓
           [GAME_OVER] → [PLAYING] (restart)
```

### Regras Detalhadas

| # | Regra | Comportamento |
|---|---|---|
| 0 | **Tutorial na primeira execução** | Na primeira vez que o jogo é aberto, exibir overlay de tutorial (seção 18) por 3s ou até o jogador tocar na tela. Flag `hasSeenTutorial` persistida via `shared_preferences`. |
| 1 | **Ordem obrigatória** | Coletar na sequência 2 → 4 → 6 → 8 → 10. Fora de ordem = perde 1 HP |
| 2 | **Continuidade após erro** | Errar NÃO bloqueia o progresso. A estrela continua disponível. O jogador pode tentar novamente a ordem correta |
| 3 | **Morte apenas com 3 erros** | Game Over só ocorre se `currentHP == 0` |
| 4 | **Estrela já coletada** | Desaparece e não interage mais |
| 5 | **Interagir sem estrela próxima** | Nada acontece (sem penalidade) |
| 6 | **Queda para fora da tela** | Player.y > 450 → perde 1 HP + respawn na última plataforma visitada |
| 7 | **Respawn** | Player volta ao centro da última plataforma onde pisou, com vy=0 |
| 8 | **HP inicial** | 3 corações |
| 9 | **Vitória** | 5/5 estrelas coletadas → tela de vitória |
| 10 | **Reinício** | Game Over ou Vitória → jogo reinicia (HP=3, estrelas restauradas, player na P1) |
| 11 | **Feedback pedagógico no erro** | Após erro de ordem, exibir "Próxima estrela: N" flutuante por 1.5s e destacar visualmente a estrela correta com brilho mais intenso |
| 12 | **Acessibilidade de cor** | Feedback de acerto/erro inclui ícone visual (✓/✗) além da cor, para jogadores com daltonismo vermelho-verde |

### Fluxo da Coleta

```
Player pressiona INTERAGIR (✋ mobile / E ou Enter web)
  ↓
Encontra estrela mais próxima dentro de 44px?
  ├── NÃO: Nada acontece
  └── SIM: É a PRÓXIMA estrela na sequência?
        ├── SIM (ordem correta):
        │     ├── Estrela desaparece (animação de coleta)
        │     ├── collectedIndex++
        │     ├── Atualiza HUD (progresso)
        │     ├── Feedback: partículas douradas + som "ding"
        │     └── Se collectedIndex == 5 → VITÓRIA
        │
        └── NÃO (ordem errada):
              ├── currentHP -= 1
              ├── Atualiza corações no HUD
              ├── Feedback: flash vermelho + shake + som "buzz"
              ├── Exibe "Próxima estrela: N" flutuante (1.5s)
              ├── Exibe ícone "✗" acima do player (0.5s)
              └── Se currentHP == 0 → GAME OVER
```

---

## 12. Estrutura de Dados (Conceitual)

```dart
// Sequência correta
const List<int> correctSequence = [2, 4, 6, 8, 10];

// Estado do jogo — estende ChangeNotifier para reatividade Flutter
class GameState extends ChangeNotifier {
  int _currentHP = 3;
  int get currentHP => _currentHP;

  int collectedIndex = 0;          // posição na sequência (0..4)
  List<int> collectedNumbers = []; // ex: [2, 4]
  List<bool> starsCollected = [false, false, false, false, false];
  int lastPlatformIndex = 0;       // para respawn
  bool isPaused = false;
  bool isGameOver = false;
  bool isVictory = false;
  Duration elapsedTime = Duration.zero; // timer da partida

  void loseHP() {
    _currentHP--;
    notifyListeners(); // ← dispara rebuild na UI Flutter
    if (_currentHP <= 0) {
      isGameOver = true;
      notifyListeners();
    }
  }

  void collectStar(int number) {
    collectedNumbers.add(number);
    collectedIndex++;
    starsCollected[collectedIndex - 1] = true;
    notifyListeners();
    if (collectedIndex >= correctSequence.length) {
      isVictory = true;
      notifyListeners();
    }
  }

  void reset() {
    _currentHP = 3;
    collectedIndex = 0;
    collectedNumbers = [];
    starsCollected = [false, false, false, false, false];
    lastPlatformIndex = 0;
    isPaused = false;
    isGameOver = false;
    isVictory = false;
    elapsedTime = Duration.zero;
    notifyListeners();
  }
}

// Dados de uma fase — parametrizável para múltiplas fases futuras
class LevelData {
  final String levelName;              // "Contar de 2 em 2"
  final List<int> sequence;            // [2, 4, 6, 8, 10]
  final List<Vector2> starPositions;   // posições das estrelas
  final List<Vector2> platformPositions; // posições das plataformas
  final int initialHP;

  const LevelData({
    required this.levelName,
    required this.sequence,
    required this.starPositions,
    required this.platformPositions,
    this.initialHP = 3,
  });
}

// Fase 1 — skip counting de 2 em 2 até 10
const LevelData level1 = LevelData(
  levelName: 'Contar de 2 em 2',
  sequence: [2, 4, 6, 8, 10],
  starPositions: [
    Vector2(100, 300),
    Vector2(240, 240),
    Vector2(380, 180),
    Vector2(520, 240),
    Vector2(640, 300),
  ],
  platformPositions: [
    Vector2(60, 340),
    Vector2(200, 280),
    Vector2(340, 220),
    Vector2(480, 280),
    Vector2(600, 340),
  ],
);

// Dados de cada estrela
class StarData {
  final int number;
  final int platformIndex;
  final Vector2 position;

  const StarData({
    required this.number,
    required this.platformIndex,
    required this.position,
  });
}

final List<StarData> starDataList = [
  StarData(number: 2,  platformIndex: 0, position: Vector2(100, 300)),
  StarData(number: 4,  platformIndex: 1, position: Vector2(240, 240)),
  StarData(number: 6,  platformIndex: 2, position: Vector2(380, 180)),
  StarData(number: 8,  platformIndex: 3, position: Vector2(520, 240)),
  StarData(number: 10, platformIndex: 4, position: Vector2(640, 300)),
];
```

---

## 13. Animações e Efeitos

### Efeitos Essenciais (Baixa Complexidade)

| Efeito | Descrição | Implementação |
|---|---|---|
| **Poeira do pulo** | 3–5 círculos brancos (3×3) com fade-out 0.3s | `ParticleComponent` com gravidade lateral |
| **Coleta correta** | Estrela scale 1→1.3→0 em 0.3s + rotação | `Tween` seqüencial |
| **Coleta errada** | Flash `rgba(229,115,115,0.3)` 0.15s + shake X | Overlay + `CameraComponent.moveBy(2,0)` |
| **Estrela pulsando** | Scale 1.0↔1.05, loop 2s, curva seno | `Tween` infinito com `SineCurve` |
| **Próxima estrela correta** | A estrela que é o próximo alvo brilha com intensidade 2× maior que as demais (glow `#FFF8DC` a 60% em vez de 30%) | Multiplicador de opacidade condicional |
| **Indicador de proximidade** | Quando player está a ≤44px de qualquer estrela, ícone "✋" pulsando (scale 1.0↔1.15, loop 0.6s) aparece acima da estrela | `Tween` com trigger de distância |
| **Player dano** | Opacidade 0.3↔1.0, 3 ciclos de 0.1s | `Tween` de opacidade |
| **Morte (Game Over)** | Fade para `#FFD0D0` em 0.5s | Overlay com fade-in |
| **Vitória** | Fade para `#FFF8DC` em 0.5s | Overlay com fade-in |

### Efeitos Desejáveis (Média Complexidade)

| Efeito | Descrição |
|---|---|
| **Partículas de vitória** | 20+ partículas douradas subindo, dispersão aleatória |
| **Brilho nas estrelas** | 3–4 partículas minúsculas (2×2) orbitando cada estrela pendente |
| **Nuvens animadas** | Movimento horizontal lento (0.1 px/frame) com wrap |
| **Grama balançando** | Wave senoidal na borda superior do chão, amplitude 2px |
| **Transição de telas** | Cortina horizontal estilo SNES entre game over e restart |
| **Sombra do player** | Elipse `rgba(0,0,0,0.2)` 16×6px abaixo do player |

### Sugestões de Animações para o Player (Futura Spritesheet)

| Animação | Frames | Duração | Descrição |
|---|---|---|---|
| **Idle** | 2 | 0.8s loop | Respiração (2px sobe/desce) |
| **Run** | 4 | 0.3s loop | Braços e pernas alternando |
| **Jump** | 1 | estático | Braços para cima, pernas encolhidas |
| **Fall** | 1 | estático | Braços abertos, pernas esticadas |
| **Hurt** | 1 | 0.3s | Expressão de dor, recuo |

### Dicas de Estilização 16-bit Nostálgica

| Técnica | Como aplicar |
|---|---|
| **Outline nos sprites** | Contorno `#2F2F2F` de 1px ao redor do player e estrelas |
| **Letterbox** | Barras `#1A1A1A` em aspect ratios não-16:9 |
| **Cores limitadas** | Máximo 4–8 cores por sprite (estilo SNES) |
| **Borda dupla em botões** | Externa escura + interna clara (bevel) |
| **Transições quadro-a-quadro** | Fade em passos de 8 frames (não linear) |

---

## 14. Recomendações de Recursos Gratuitos

### 14.1 SFX (Efeitos Sonoros)

| Site | URL | Licença | Palavras-chave de busca |
|---|---|---|---|
| **OpenGameArt** | https://opengameart.org | CC0 / CC-BY | "8bit sfx", "retro sounds", "platformer sfx" |
| **Freesound** | https://freesound.org | CC0 (filtrar) | "retro video game sfx", "chiptune jump" |
| **Pixabay Music** | https://pixabay.com/music/ | CC0 (Pixabay) | "retro game sound effect", "8 bit coin" |
| **Zapsplat** | https://www.zapsplat.com | Free (atribuição opcional) | "retro", "8 bit", "video game sfx" |
| **BFXR** | https://www.bfxr.net | **Gerador** — sem licença | Gera seus próprios SFX (recomendado) |
| **jsfxr** | https://sfxr.me | **Gerador** — sem licença | Versão online do sfxr |

**Recomendação principal:** Use **BFXR** para gerar todos os SFX. É gratuito, não tem problemas de licença (você cria do zero), e produz sons autênticos de 8-bit/16-bit.

### 14.2 BGM (Música de Fundo)

| Site | Licença | Palavras-chave |
|---|---|---|
| **OpenGameArt** | CC0 / CC-BY | "chiptune music", "platformer bgm", "retro game music loop" |
| **Pixabay Music** | CC0 | "chiptune loop", "retro game background music" |
| **Free Music Archive** | CC (verificar) | "chiptune", "8-bit music", "retro platformer" |
| **Incompetech (Kevin MacLeod)** | CC-BY 4.0 | "chiptune", "8 bit", "video game" — requer atribuição |
| **Bandcamp** (filtrar: creative commons) | CC (verificar) | tag "chiptune" + "creative commons" |

### 14.3 Fontes

| Fonte | URL | Licença |
|---|---|---|
| **Press Start 2P** | https://fonts.google.com/specimen/Press+Start+2P | SIL OFL 1.1 |
| **VT323** (alternativa) | https://fonts.google.com/specimen/VT323 | SIL OFL 1.1 |
| **Pixelify Sans** (alternativa) | https://fonts.google.com/specimen/Pixelify+Sans | SIL OFL 1.1 |

### 14.4 Artes e Sprites

| Site | Licença | Palavras-chave |
|---|---|---|
| **Kenney.nl** | CC0 (tudo) | "Platformer Pack", "Pixel Platformer", "UI Pack" |
| **OpenGameArt** | CC0 / CC-BY | "16bit character", "platformer tileset", "retro sprites" |
| **itch.io** (filtrar: free) | CC0 / CC-BY | "pixel art assets", "16x16 sprites", "platformer" |
| **CraftPix** | Free c/ atribuição | "platform game assets", "2d retro character" |

---

## 15. Implementação no Flutter / Flame

### Configuração da Câmera

```dart
class SkipperGame extends FlameGame with HasCollisionDetection {
  SkipperGame() : super(
    camera: CameraComponent.withFixedResolution(
      width: 800,
      height: 450,
      viewfinder: Viewfinder()..anchor = Anchor.topLeft,
    ),
  );

  @override
  Future<void> onLoad() async {
    // World layer (afetado pela câmera)
    world.add(BackgroundComponent());   // céu, nuvens, colinas (pré-renderizado)
    world.add(PlatformsComponent());    // todas as plataformas
    world.add(StarsComponent());        // todas as estrelas
    world.add(PlayerComponent());       // player + física

    // HUD layer (camera.viewport — não afetado pela câmera)
    // SEM segunda CameraComponent — usa o viewport da câmera principal
    camera.viewport.add(HUDComponent());           // corações + progresso + pause + timer
    camera.viewport.add(TouchControlsComponent()); // botões touch
  }
}
```

**Por que `camera.viewport` em vez de segunda câmera:**
- O Flame já fornece `camera.viewport` exatamente para conteúdo HUD estático
- Componentes adicionados ao viewport não são afetados por transformações da câmera
- Como o jogo não tem movimento de câmera, a distinção mundo/HUD é puramente organizacional — mas usar o viewport é a forma idiomática e "future-proof"
- Evita complexidade desnecessária de gerenciar duas câmeras

### Estrutura de Componentes

| Componente | Classe | Mixins Necessários | Responsabilidade |
|---|---|---|---|
| **Fundo** | `BackgroundComponent` | `Component` | Carrega e desenha background pré-renderizado em cache |
| **Plataforma** | `PlatformComponent` | `PositionComponent` | Dados de posição/dimensão para colisão manual (sem hitbox Flame) |
| **Estrela** | `StarComponent` | `PositionComponent`, `CollisionCallbacks` | Interação com player via sistema de colisão do Flame |
| **Player** | `PlayerComponent` | `PositionComponent`, `KeyboardHandler` | Física manual, input, animação. Hitbox própria para colisão com estrelas. |
| **HUD** | `HUDComponent` | `Component` | Corações, progresso, timer, pause btn |
| **TouchControls** | `TouchControlsComponent` | `Component` | Botões touch overlay |

**Divisão de responsabilidade de colisão:**
- **Player ↔ Plataforma / Chão:** colisão física MANUAL (AABB no `update()`) — mais simples e previsível para colisão one-way
- **Player ↔ Estrela:** via `CollisionCallbacks` + `CircleHitbox` de raio 44px na estrela — interação simples sem física de pouso
- **Plataformas NÃO** têm hitboxes Flame — apenas posição/dimensão como dados

### Detecção de Colisão (Conceitual)

**Colisão física — MANUAL no `update()` do PlayerComponent:**
```dart
void update(double dt) {
  // Aplicar gravidade
  vy += gravity * dt;
  vy = vy.clamp(-double.infinity, vMaxY);

  // Aplicar movimento horizontal
  x += vx * dt;
  y += vy * dt;

  // Verificar colisão com plataformas (one-way: só por cima)
  checkPlatformCollision();
  // Verificar colisão com o chão
  checkGroundCollision();
  // Manter player dentro da tela
  clampToScreenBounds();
  // Verificar queda
  checkFall();
}

// Colisão one-way com plataforma (só pousa por cima):
bool isLandingOn(PlatformComponent platform) {
  return vy > 0                                                          // caindo
      && y + height >= platform.y && previousBottom <= platform.y        // cruzou o topo
      && x + width  > platform.x && x < platform.x + platform.width;     // dentro do X
}
```

**Colisão de interação — via `CollisionCallbacks` do Flame (estrelas):**
```dart
class StarComponent extends PositionComponent with CollisionCallbacks {
  StarComponent() : super(
    children: [CircleHitbox(radius: 22)], // raio 44px de interação
  );

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is PlayerComponent) {
      // Sinaliza para o player que pode interagir com esta estrela
    }
  }
}
```

### Portabilidade Mobile → Web

| Aspecto | Android | Web | Código igual? |
|---|---|---|---|
| Renderização | Skia / Impeller | CanvasKit (WebGL) | Sim |
| Touch | `GestureDetector` nativo | Eventos pointer do navegador | Sim (Flutter abstrai) |
| Teclado | Hardware keyboard | `document.addEventListener` | Sim (`KeyboardHandler`) |
| Áudio | `AudioPool` | `AudioPool` (WebAudio) | Sim |
| Fontes | .ttf empacotado | Google Fonts CDN ou .ttf | Sim |
| Fullscreen | `SystemChrome` | Fullscreen API | Precisa de plugin |

### Performance — Background Pré-Renderizado

O background (céu + colinas + nuvens) é majoritariamente estático. Para evitar redesenhá-lo a cada frame, pré-renderizar uma única vez no `onLoad`:

```dart
class BackgroundComponent extends Component {
  late final Image _cachedBackground;

  @override
  Future<void> onLoad() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    _drawBackground(canvas); // desenha céu + colinas + nuvens no canvas
    final picture = recorder.endRecording();
    _cachedBackground = await picture.toImage(800, 450);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImage(_cachedBackground, Offset.zero, Paint());
  }
}
```

Isso elimina o custo de recalcular gradiente + arcos a cada frame — especialmente relevante para Android de entrada e navegadores Web.

### Telas de Estado — Flutter Overlays

As telas de Pausa, Vitória e Game Over são implementadas como Flutter overlays via `GameWidget.overlayBuilderMap`. O layout usa widgets responsivos (`Center`, `Column`, `SizedBox`) em vez de coordenadas absolutas — adaptando-se automaticamente a qualquer resolução real de tela.

```dart
GameWidget(
  game: _game,
  overlayBuilderMap: {
    'pause': (context, game) => const PauseOverlay(),
    'victory': (context, game) => VictoryOverlay(gameState: game.state),
    'gameOver': (context, game) => GameOverOverlay(gameState: game.state),
    'tutorial': (context, game) => TutorialOverlay(),
  },
);
```

---

## 16. Estrutura de Arquivos

```
skipper/
├── pubspec.yaml
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # MaterialApp, rotas
│   ├── game/
│   │   ├── skipper_game.dart              # FlameGame principal (HasCollisionDetection)
│   │   ├── game_state.dart                # Estado do jogo (ChangeNotifier)
│   │   ├── level_data.dart                # Dados parametrizáveis de fases
│   │   ├── components/
│   │   │   ├── player.dart                # PlayerComponent (física manual)
│   │   │   ├── platform.dart              # PlatformComponent (dados de colisão)
│   │   │   ├── star.dart                  # StarComponent (CollisionCallbacks)
│   │   │   └── background_cache.dart      # Background pré-renderizado
│   │   ├── screens/
│   │   │   ├── game_screen.dart           # Tela da fase
│   │   │   ├── pause_overlay.dart         # Overlay de pausa
│   │   │   ├── victory_screen.dart        # Tela de vitória
│   │   │   └── game_over_screen.dart      # Tela de game over
│   │   ├── ui/
│   │   │   ├── hud.dart                   # HUD (corações + progresso + pause)
│   │   │   ├── touch_controls.dart        # Botões touch
│   │   │   └── keyboard_input.dart        # Input de teclado
│   │   └── config/
│   │       ├── game_config.dart           # Constantes do jogo
│   │       ├── level_data.dart            # Posicionamento das plataformas/estrelas
│   │       └── palette.dart               # Constantes de cor
│   └── theme/
│       └── text_styles.dart               # Estilos de texto centralizados
├── assets/
│   ├── images/
│   │   ├── hud/
│   │   │   ├── heart_full.png
│   │   │   ├── heart_empty.png
│   │   │   ├── btn_arrow_left.png
│   │   │   ├── btn_arrow_right.png
│   │   │   ├── btn_jump.png
│   │   │   ├── btn_interact.png
│   │   │   └── pause_icon.png
│   │   └── objects/
│   │       └── star.png
│   ├── fonts/
│   │   ├── PressStart2P.ttf
│   │   └── PixelifySans.ttf
│   └── audio/
│       └── (futuramente: sfx/*.wav, bgm/*.ogg)
├── docs/
│   └── PLANEJAMENTO.md                    # ← Este arquivo
├── android/
└── web/
```

---

## 17. Tabela Mestra de Posicionamentos

Resolução virtual: **800 × 450 px**

| Item | X | Y | Largura | Altura | Layer (z) | Notas |
|---|---|---|---|---|---|---|
| **HUD fundo** | 0 | 0 | 800 | 48 | 100 | `#2F2F2F` @ 75% |
| **Coração 1** | 16 | 10 | 32 | 32 | 101 | Swap sprite |
| **Coração 2** | 54 | 10 | 32 | 32 | 101 | — |
| **Coração 3** | 92 | 10 | 32 | 32 | 101 | — |
| **Texto progresso** | 240 | 14 | 320 | 28 | 101 | Centralizado |
| **Timer** | 640 | 14 | 80 | 28 | 101 | "00:00", `#E0E0E0` |
| **Botão pausa** | 758 | 10 | 32 | 32 | 101 | Sprite 32×32 |
| **Céu (gradiente)** | 0 | 48 | 800 | 252 | 0 | `#87CEEB`→`#B0E0E6` |
| **Nuvem 1** | 100 | 85 | 60 | 24 | 1 | `#FFFAFA` @ 75% |
| **Nuvem 2** | 350 | 70 | 72 | 26 | 1 | `#FFFAFA` @ 70% |
| **Nuvem 3** | 580 | 90 | 56 | 22 | 1 | `#FFFAFA` @ 75% |
| **Colina 1** | 0 | 280 | 800 | 60 | 1 | `#98FB98` |
| **Colina 2** | 0 | 300 | 800 | 50 | 2 | `#90EE90` |
| **Plataforma 1** | 60 | 340 | 120 | 16 | 10 | — |
| **Estrela 1** (nº 2) | 100 | 300 | 40 | 40 | 11 | Sobre P1 |
| **Plataforma 2** | 200 | 280 | 120 | 16 | 10 | — |
| **Estrela 2** (nº 4) | 240 | 240 | 40 | 40 | 11 | Sobre P2 |
| **Plataforma 3** | 340 | 220 | 120 | 16 | 10 | — |
| **Estrela 3** (nº 6) | 380 | 180 | 40 | 40 | 11 | Sobre P3 |
| **Plataforma 4** | 480 | 280 | 120 | 16 | 10 | — |
| **Estrela 4** (nº 8) | 520 | 240 | 40 | 40 | 11 | Sobre P4 |
| **Plataforma 5** | 600 | 340 | 120 | 16 | 10 | — |
| **Estrela 5** (nº 10) | 640 | 300 | 40 | 40 | 11 | Sobre P5 |
| **Player** | 108 | 310 | 24 | 30 | 12 | Sobre P1, hitbox: (2,2,20,28) |
| **Chão (grama)** | 0 | 390 | 800 | 12 | 5 | `#6B8E23` |
| **Chão (terra)** | 0 | 402 | 800 | 34 | 5 | `#DEB887` |
| **Chão (sombra)** | 0 | 436 | 800 | 14 | 5 | `#D2B48C` |
| **← botão** | 20 | 378 | 56 | 56 | 200 | Hitbox: (16,370,62,72) |
| **→ botão** | 84 | 378 | 56 | 56 | 200 | Hitbox: (82,370,62,72) |
| **⬆ botão** | 636 | 370 | 60 | 60 | 200 | Hitbox: (628,360,70,80) |
| **✋ botão** | 710 | 370 | 60 | 60 | 200 | Hitbox: (704,360,70,80) |
| **Overlay pausa** | 0 | 0 | 800 | 450 | 999 | `rgba(0,0,0,0.6)` |
| **"PAUSADO" texto** | 400 | 180 | — | — | 1000 | Centralizado, 32px |
| **"CONTINUAR" botão** | 290 | 235 | 220 | 50 | 1000 | Centralizado |
| **Texto "Próxima: N"** | — | — | — | — | 1000 | Flutuante sobre player, efêmero 1.5s |
| **Ícone ✓/✗** | — | — | — | — | 1000 | Flutuante sobre player, efêmero 0.5s |
| **Overlay vitória** | 0 | 0 | 800 | 450 | 999 | Gradiente dourado |
| **"VITÓRIA!" texto** | 400 | 150 | — | — | 1000 | Centralizado, 36px |
| **"JOGAR NOVAMENTE" btn** | 270 | 325 | 260 | 50 | 1000 | Centralizado |
| **Overlay game over** | 0 | 0 | 800 | 450 | 999 | Gradiente vermelho |
| **"FIM DE JOGO" texto** | 400 | 170 | — | — | 1000 | Centralizado, 32px |
| **"TENTAR NOVAMENTE" btn** | 270 | 255 | 260 | 50 | 1000 | Centralizado |

---

## 18. Tutorial — Primeira Execução

Exibido apenas na primeira vez que o jogo é aberto (flag `hasSeenTutorial` em `shared_preferences`). O jogador pode fechar tocando em qualquer lugar da tela ou aguardar 3 segundos.

### Fundo

| Propriedade | Valor |
|---|---|
| **Forma** | Retângulo 800×450 |
| **Cor** | `rgba(0, 0, 0, 0.75)` |
| **Borda** | 2px `#FFD700` |

### Título "BEM-VINDO AO SKIPPER!"

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "BEM-VINDO AO SKIPPER!" |
| **Posição** | X=400, Y=100 |
| **Fonte** | Press Start 2P, 20px |
| **Cor** | `#FFD700` |
| **Alinhamento** | Centralizado |

### Instrução Principal

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "COLETE AS ESTRELAS NA ORDEM CORRETA" |
| **Posição** | X=400, Y=170 |
| **Fonte** | Pixelify Sans, 16px |
| **Cor** | `#FFFFFF` |
| **Alinhamento** | Centralizado |

### Sequência Visual

| Propriedade | Valor |
|---|---|
| **Conteúdo** | " 2  →  4  →  6  →  8  →  10 " |
| **Posição** | X=400, Y=220 |
| **Fonte** | Press Start 2P, 22px |
| **Cor** | `#FFD700` |
| **Alinhamento** | Centralizado |
| **Destaque** | Setas "→" em `#E0E0E0` |

### Instrução de Controles

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "Use os botões para pular e andar" |
| **Posição** | X=400, Y=280 |
| **Fonte** | Pixelify Sans, 13px |
| **Cor** | `#9E9E9E` |
| **Alinhamento** | Centralizado |

### Chamada para Ação

| Propriedade | Valor |
|---|---|
| **Conteúdo** | "(toque na tela para começar)" |
| **Posição** | X=400, Y=350 |
| **Fonte** | Pixelify Sans, 11px |
| **Cor** | `#E0E0E0` |
| **Alinhamento** | Centralizado |
| **Animação** | Pulsação de opacidade 0.5↔1.0, loop 1.5s |

**Lógica de persistência:**
```dart
final prefs = await SharedPreferences.getInstance();
if (!prefs.containsKey('hasSeenTutorial') || prefs.getBool('hasSeenTutorial') == false) {
  game.showTutorial = true;
  prefs.setBool('hasSeenTutorial', true);
}
```

---

## 19. Timer e Ranking Local

### Timer

| Propriedade | Valor |
|---|---|
| **Formato** | `MM:SS` |
| **Precisão** | Segundos (atualiza a cada 1s) |
| **Início** | Quando o primeiro input do jogador é detectado (primeiro toque/tecla após load) |
| **Parada** | Vitória ou Game Over |
| **Exibição** | HUD, canto superior direito, ao lado do botão pause |

### Ranking Local

| Propriedade | Valor |
|---|---|
| **Armazenamento** | `shared_preferences`, chave `skipper_best_times` |
| **Formato do dado** | `List<String>` com 3 tempos em `MM:SS`, ordenados do menor para o maior |
| **Atualização** | Ao final de cada vitória, insere o tempo atual na lista, ordena, trunca para 3 |
| **Exibição** | Tela de vitória, abaixo do tempo atual |
| **Emojis de ranking** | 🥇 (1º), 🥈 (2º), 🥉 (3º) |

```dart
class RankingService {
  static const _key = 'skipper_best_times';

  static Future<List<String>> getBestTimes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> submitTime(Duration time) async {
    final prefs = await SharedPreferences.getInstance();
    final times = await getBestTimes();
    final formatted = '${time.inMinutes.toString().padLeft(2, '0')}:'
                      '${(time.inSeconds % 60).toString().padLeft(2, '0')}';
    times.add(formatted);
    times.sort();
    prefs.setStringList(_key, times.take(3).toList());
  }
}
```

---

## 20. Acessibilidade

### Daltonismo Vermelho-Verde

O jogo não depende exclusivamente de cor para comunicar estado:

| Situação | Canal visual de cor | Canal alternativo (não depende de cor) |
|---|---|---|
| **Coleta correta** | Glow verde (`#81C784`) | Ícone "✓", partículas douradas, som "ding" |
| **Coleta errada** | Flash vermelho (`#E57373`) | Ícone "✗", shake de tela (2px), som "buzz" |
| **Estrela correta (próximo alvo)** | Glow 2× mais intenso | Pulsação diferenciada, indicador "✋" ao se aproximar |
| **Coração cheio vs. vazio** | Cor do sprite | Sprites DIFERENTES (`heart_full.png` / `heart_empty.png`) — silhueta distinta |

### Legibilidade de Fonte

| Contexto | Fonte | Tamanho mínimo | Justificativa |
|---|---|---|---|
| Títulos (VITÓRIA, PAUSADO, FIM DE JOGO) | Press Start 2P | 20px+ | Baixa densidade de caracteres, legibilidade aceitável |
| HUD (progresso, timer) | Press Start 2P | 14px | Poucos caracteres, contexto fixo |
| Textos longos (instruções, subtextos) | Pixelify Sans | 12px+ | Glifos mais largos e respiráveis, melhor para leitura corrida |
| Números nas estrelas | Press Start 2P | 16px | Destaque, apenas 1–2 dígitos |

### Área de Toque

Todos os botões touch têm área de toque **significativamente maior** que o sprite visual:
- Botões de movimento (56×56 sprite): hitbox 62×72
- Botões de ação (60×60 sprite): hitbox 70×80
- Botão pause (32×32 sprite): hitbox 48×48
- Estrelas (40×40 sprite): hitbox de interação 56×56

Nenhuma hitbox se sobrepõe (gap mínimo de 4px entre pares adjacentes).

---

**Fim do documento de planejamento.** Qualquer alteração ou refinamento pode ser registrado como nova versão neste mesmo arquivo.
