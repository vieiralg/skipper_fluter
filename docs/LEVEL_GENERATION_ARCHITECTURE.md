# Nova Arquitetura de Geração Procedural

Este documento descreve a refatoração do gerador procedural do Skipper para que os níveis deixem de parecer plataformas aleatórias e passem a parecer fases desenhadas por level designer humano.

Objetivo:

- manter completabilidade matemática
- respeitar a física real do jogador
- manter compatibilidade Flutter + Flame
- evitar layouts lineares, repetitivos ou sem identidade
- produzir fases com arquétipo visual claro

---

# 1. Problema Atual

O gerador atual garante alcance, mas não garante intenção visual.

Problemas observados:

- muitas plataformas alinhadas na mesma altura
- pouca variação vertical
- ausência de objetivo visual
- sensação de placeholder
- estrelas sempre previsíveis
- pouca identidade entre níveis

Conclusão:

O gerador não deve pensar apenas em `plataformas alcançáveis`.

Ele deve pensar em `tipos de fase`.

---

# 2. Nova Ideia Central

Todo nível deve começar pela escolha de um arquétipo visual.

```dart
enum LayoutArchetype {
  stairUp,
  stairDown,
  zigZag,
  peak,
  valley,
  mixed,
}
```

Fluxo novo:

```text
LevelDefinition
  ↓
DifficultyManager
  ↓
Escolha do LayoutArchetype
  ↓
LevelGenerator
  ↓
Validação física + visual
  ↓
GeneratedLevel
```

---

# 3. Arquitetura Obrigatória

## 3.1 LevelDefinition

Responsabilidade:

- descrever a intenção do nível
- não conter posições finais
- definir contagem, dificuldade, faixa de números e quantidade de plataformas

Campos sugeridos:

```dart
class LevelDefinition {
  final int levelNumber;
  final String title;
  final int skipStep;
  final int startValue;
  final int endValue;
  final int platformCount;
  final int distractorCount;
  final Difficulty difficulty;
}
```

## 3.2 DifficultyManager

Responsabilidade:

- mapear nível → regras de dificuldade
- definir limites de gaps, variação vertical, tentativas máximas e largura de plataforma

Exemplo:

```dart
class DifficultyRules {
  final double minGapX;
  final double maxGapX;
  final double maxClimbY;
  final double maxDropY;
  final int maxAttempts;
  final double minPlatformWidth;
  final double maxPlatformWidth;
}
```

## 3.3 LevelGenerator

Responsabilidade:

1. escolher um arquétipo
2. gerar plataforma principal em cadeia
3. aplicar variação controlada
4. inserir plataformas de apoio quando necessário
5. validar física
6. validar sobreposição
7. validar limites da tela
8. validar legibilidade visual
9. gerar estrelas
10. gerar distratores
11. produzir `GeneratedLevel`

## 3.4 GeneratedLevel

Responsabilidade:

- guardar o resultado final da geração
- servir de entrada para `SkipperGame`

Campos sugeridos:

```dart
class GeneratedLevel {
  final int levelNumber;
  final String title;
  final int seed;
  final LayoutArchetype archetype;
  final List<PlatformData> platforms;
  final List<StarData> stars;
  final List<int> correctSequence;
}
```

## 3.5 PlatformSpawner

Responsabilidade:

- converter `PlatformData` em `PlatformComponent`
- inserir no `world`
- configurar largura, posição, índice e flag de apoio

## 3.6 StarSpawner

Responsabilidade:

- converter `StarData` em `StarComponent`
- posicionar estrela na plataforma correta
- aplicar offsetX aleatório dentro da margem segura

## 3.7 ProgressManager

Responsabilidade:

- desbloqueio de níveis
- conclusão de níveis
- melhor tempo por nível
- persistência do progresso

## 3.8 SaveManager

Responsabilidade:

- salvar/ler progresso via `SharedPreferences`
- manter chaves organizadas e estáveis

## 3.9 LevelSelectScreen

Responsabilidade:

- exibir níveis desbloqueados
- mostrar status concluído/bloqueado
- iniciar nível selecionado

---

# 4. Estruturas de Dados

## 4.1 PlatformData

```dart
class PlatformData {
  final int id;
  final Vector2 position;
  final double width;
  final double height;
  final bool isSupportPlatform;
}
```

## 4.2 StarData

```dart
class StarData {
  final int value;
  final int platformId;
  final double offsetX;
  final bool isCorrect;
}
```

## 4.3 GeneratedLevel

```dart
class GeneratedLevel {
  final int levelNumber;
  final String title;
  final int seed;
  final LayoutArchetype archetype;
  final List<PlatformData> platforms;
  final List<StarData> stars;
  final List<int> correctSequence;
}
```

---

# 5. Arquétipos de Layout

## 5.1 Stair Up

```text
P0
  ↗
P1
   ↗
P2
    ↗
P3
     ↗
P4
```

Características:

- sensação de avanço
- leitura simples
- ideal para níveis iniciais

## 5.2 Stair Down

```text
P0
 ↘
  P1
   ↘
    P2
     ↘
      P3
```

Características:

- introduz descida
- visual limpo

## 5.3 Zig Zag

```text
P0      ↗      P1
       ↘
P2      ↗      P3
```

Características:

- navegação dinâmica
- ritmo constante

## 5.4 Peak

```text
        P2

   P1         P3

P0               P4
```

Características:

- topo visual forte
- objetivo percebido imediatamente

## 5.5 Valley

```text
P0               P4

   P1         P3

        P2
```

Características:

- sensação de descida e retorno
- leitura de “vale” no centro

## 5.6 Mixed

Mistura controlada dos anteriores.

- um trecho em escada
- um pico central
- uma pequena mudança de direção

---

# 6. Regras Visuais Obrigatórias

## 6.1 Nenhuma Linha Reta

Rejeitar se mais de 3 plataformas tiverem praticamente o mesmo Y.

Critério sugerido:

```dart
if (countPlatformsWithSameYBand > 3) reject;
```

Ou por tolerância:

```dart
if (countPlatformsWhere((y - medianY).abs() < 8) > 3) reject;
```

## 6.2 Variação Vertical Mínima

Calcular:

```text
maxY - minY
```

Se for menor que `120 px`, rejeitar.

## 6.3 Primeira Plataforma

Não pode ser inalcançável a partir do spawn.

Regras:

- usar alcance real do jogador
- respeitar limite horizontal/vertical calculado
- permitir leitura visual imediata

## 6.4 Objetivo Visual

Todo layout deve ter pelo menos um destes elementos:

- ponto alto
- ponto baixo
- padrão visual claro

## 6.5 Distribuição Horizontal

Evitar gaps uniformes.

Bom exemplo:

```text
85, 110, 95, 120
```

Ruim exemplo:

```text
100, 100, 100, 100
```

---

# 7. Estrelas

As estrelas não devem ficar sempre centralizadas.

Regra:

```dart
offsetX = random(margemSegura, larguraDaPlataforma - margemSegura);
```

Recomendação:

- margem segura: `20 px`
- garantir que o número continue legível
- evitar mesma posição relativa em todas as plataformas

---

# 8. Plataformas de Apoio

Adicionar suporte para:

```dart
isSupportPlatform
```

Essas plataformas:

- não possuem estrela
- existem apenas para melhorar navegação
- ajudam a quebrar linearidade visual

Exemplo:

```text
P0

      suporte

           P1

                suporte

                     P2
```

---

# 9. Validação Visual

Antes de aceitar um layout, validar:

- quantidade de alturas diferentes
- distribuição horizontal
- existência de arquétipo identificável
- existência de objetivo visual
- primeira plataforma alcançável

Rejeitar se:

- parecer linha reta
- parecer agrupamento sem identidade
- existir variação vertical menor que 120px
- houver gaps uniformes demais

---

# 10. Fluxo Completo do LevelGenerator

```text
LevelDefinition
  ↓
DifficultyManager
  ↓
escolher LayoutArchetype
  ↓
gerar cadeia principal
  ↓
adicionar plataformas de apoio
  ↓
validar tela
  ↓
validar sobreposição
  ↓
validar alcance
  ↓
validar estética
  ↓
gerar estrelas
  ↓
gerar distratores
  ↓
GeneratedLevel
```

---

# 11. Regras de Geração por Arquétipo

## 11.1 Stair Up

- Y sobe gradualmente
- gaps horizontais variam levemente
- primeira plataforma próxima ao chão
- última plataforma no ponto mais alto do layout

## 11.2 Stair Down

- Y desce gradualmente
- cria sensação de avanço sem esforço excessivo

## 11.3 Zig Zag

- alterna subida e descida
- nunca mais que 2 plataformas na mesma faixa de Y

## 11.4 Peak

- uma plataforma central mais alta que as demais
- laterais mais baixas
- excelente para criar “objetivo” visual

## 11.5 Valley

- centro mais baixo que as laterais
- cria contraste e leitura clara

## 11.6 Mixed

- combina segmentos curtos dos anteriores
- usado para níveis intermediários e avançados

---

# 12. 20 Exemplos de Layouts Visuais

Observação:

- os exemplos abaixo são conceituais
- não são coordenadas finais
- mostram apenas a identidade visual do layout

## 12.1 Stair Up

```text
P0
  P1
    P2
      P3
        P4
```

## 12.2 Stair Up com apoio

```text
P0
  suporte
     P1
        P2
          suporte
             P3
                P4
```

## 12.3 Stair Down

```text
        P0
      P1
    P2
  P3
P4
```

## 12.4 Zig Zag 1

```text
P0      P1
    P2      P3
         P4
```

## 12.5 Zig Zag 2

```text
    P0
P1        P2
    P3        P4
```

## 12.6 Peak 1

```text
        P2

   P1         P3

P0               P4
```

## 12.7 Peak 2 com apoio

```text
        P2
   suporte

 P1             P3

P0                 P4
```

## 12.8 Valley 1

```text
P0                 P4

   P1         P3

        P2
```

## 12.9 Valley 2 com apoio

```text
P0               P4
    suporte

   P1         P3

        P2
```

## 12.10 Mixed 1

```text
P0
  P1
    P2
  P3
      P4
```

## 12.11 Mixed 2

```text
    P0
P1        P2
   P3
         P4
```

## 12.12 Mixed 3 com pico

```text
        P2
P0   P1        P3
             P4
```

## 12.13 Mixed 4 com vale

```text
P0          P4
   P1    P3
       P2
```

## 12.14 Stair Up curto

```text
P0
  P1
   P2
    P3
     P4
```

## 12.15 Stair Down curto

```text
     P0
    P1
   P2
  P3
 P4
```

## 12.16 Zig Zag com apoio

```text
P0    suporte    P1
    P2      suporte    P3
         P4
```

## 12.17 Peak assimétrico

```text
            P2
P0   P1                P3
                 P4
```

## 12.18 Valley assimétrico

```text
P0               P4
       P1   P3
            P2
```

## 12.19 Mixed longo

```text
P0
   P1
      P2
   P3
         P4
```

## 12.20 Peak + Zig Zag

```text
        P2
P0          P1
    P3          P4
```

---

# 13. Diagramas ASCII do Sistema

## 13.1 Geração Principal

```text
spawn -> P0 -> P1 -> P2 -> P3 -> P4
```

## 13.2 Validação

```text
[layout candidato]
      ↓
[alcance físico]
      ↓
[sem overlap]
      ↓
[boa leitura visual]
      ↓
[aceito]
```

## 13.3 Densidade Visual

```text
ruim:  P0 P1 P2 P3 P4 na mesma linha

bom:

P0
   P1
      P2
   P3
        P4
```

---

# 14. Critérios de Aceitação

Um nível só pode ser aceito se:

1. a primeira plataforma for alcançável a partir do spawn
2. o percurso principal existir sem interrupções
3. não houver colisão de plataformas
4. não houver colisão de estrelas
5. a tela estiver respeitada
6. a leitura visual for clara
7. o layout tiver arquétipo reconhecível
8. a variação vertical total for pelo menos 120px
9. as estrelas forem distribuídas com offsetX variado
10. o nível puder ser reproduzido por seed

---

# 15. Resultado Esperado

O gerador deve produzir níveis que pareçam:

- desenhados manualmente
- consistentes visualmente
- distintos entre si
- completáveis por construção
- educativos e legíveis

Em vez de apenas:

- plataformas válidas
- posições aleatórias
- layout técnico sem identidade
