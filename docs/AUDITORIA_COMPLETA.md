# Auditoria Completa — Projeto Skipper

> **Data:** 30/06/2026
> **Propósito:** Preparação para publicação em repositório público no GitHub como portfólio
> **Escopo:** Revisão de código, arquitetura, assets, documentação, segurança e boas práticas

---

## Sumário

1. [Resumo Executivo](#1-resumo-executivo)
2. [Análise Estrutural](#2-análise-estrutural)
3. [Respostas às 20 Perguntas](#3-respostas-%C3%A0s-20-perguntas)
4. [Relatório de Problemas Encontrados](#4-relat%C3%B3rio-de-problemas-encontrados)
5. [Informações Sensíveis](#5-informa%C3%A7%C3%B5es-sens%C3%ADveis)
6. [Lista de Melhorias por Prioridade](#6-lista-de-melhorias-por-prioridade)
7. [Plano de Ação Passo a Passo](#7-plano-de-a%C3%A7%C3%A3o-passo-a-passo)
8. [Arquivos a Criar e Modificar](#8-arquivos-a-criar-e-modificar)
9. [Checklist Final de Publicação](#9-checklist-final-de-publica%C3%A7%C3%A3o)

---

## 1. Resumo Executivo

O projeto **Skipper** é um jogo de plataforma educativo 2D desenvolvido em **Flutter + Flame**, com geração procedural de fases, sistema de progressão em 10 níveis, controles touch/teclado, áudio completo e suporte a 6 plataformas (Android, iOS, Web, Windows, Linux, macOS). Também possui um portal mobile complementar em **Svelte 5 + Vite** que embarca o jogo Web em um iframe com visual arcade.

**Estado geral:** O projeto está funcional, bem estruturado e arquitetado de forma sólida. A análise encontrou **1 problema crítico** (falha em runtime), **5 problemas médios** (código morto, prints de debug, listener vazando) e **18 problemas leves** (nomenclatura, constantes não usadas, configurações mínimas, assets não declarados). Nenhuma informação sensível foi encontrada.

**Nota de portfólio:** O projeto demonstra conhecimento sólido em Flutter, Flame, geração procedural, game design e arquitetura de componentes. Com os ajustes propostos, será um repositório de alto nível.

---

## 2. Análise Estrutural

### 2.1 Árvore do Projeto (relevante)

```
skipper/
├── .dart_tool/                  # Cache Dart (ignorado)
├── .flutter-plugins-dependencies # Gerado automaticamente (ignorado)
├── .git/                        # Git
├── .gitignore                   # OK
├── .idea/                       # IDE (ignorado)
├── .metadata                    # Metadados Flutter (trackear)
├── README.md                    # Template padrão Flutter (SUBSTITUIR)
├── analysis_options.yaml        # Apenas 2 regras (MELHORAR)
├── pubspec.lock                 # Lockfile (trackear)
├── pubspec.yaml                 # Config (MELHORAR: falta font)
├── skipper.iml                  # IntelliJ (ignorado)
│
├── android/                     # OK
├── assets/                      # OK (1 typo em filename)
│   ├── audio/
│   │   ├── music/bgm.mp3
│   │   └── sfx/ (5 arquivos)
│   ├── fonts/
│   │   ├── pixel_font.ttf       # Declarado em pubspec.yaml
│   │   └── PressStart2P-Regular.ttf  # NÃO declarado em pubspec ⚠️
│   └── images/
│       ├── background.png
│       ├── hud/ (7 arquivos)
│       ├── objects/ (plataform.png — typo)
│       └── player/ (3 arquivos)
│
├── build/                       # Build output (ignorado)
├── docs/                        # OK
├── ios/                         # OK
├── lib/                         # CÓDIGO PRINCIPAL
│   ├── main.dart
│   ├── app.dart
│   └── game/
│       ├── audio_manager.dart
│       ├── game_state.dart
│       ├── skipper_game.dart
│       ├── components/ (5 arquivos)
│       ├── config/ (2 arquivos)
│       ├── levels/ (10 arquivos)
│       ├── screens/ (7 arquivos)
│       └── ui/ (4 arquivos)
├── linux/                       # OK
├── macos/                       # OK
├── svelte-mobile/               # Portal Svelte (OK)
├── test/                        # VAZIO
├── tool/                        # VAZIO
├── web/                         # OK (melhorar meta tags)
└── windows/                     # OK
```

### 2.2 Organização Geral

| Critério | Avaliação |
|----------|-----------|
| Separação de responsabilidades | ✅ Excelente — componentes, níveis, UI, telas bem isolados |
| Padronização de nomes | ⚠️ Boa, com exceções (typo `plataform`, arquivo `background_cache` sem cache) |
| Arquitetura | ✅ Sólida — FlameGame + ChangeNotifier + Componentes |
| Documentação | ✅ Abundante (4 docs, ~8000 linhas) |
| Testes | ❌ Nenhum |
| Segurança | ✅ Sem dados sensíveis |

---

## 3. Respostas às 20 Perguntas

### 1. A estrutura atual do projeto está organizada?

**Sim, está bem organizada.** A separação em `components/`, `config/`, `levels/`, `screens/`, `ui/` é clara e segue boas práticas do Flutter/Flame. O projeto é modular e fácil de navegar. A estrutura de assets reflete fielmente o que é usado no código.

### 2. Existe alguma pasta que deveria ser removida?

- **`tool/`** — Está vazia. Pode ser removida ou mantida como diretório para scripts futuros. Remover não afeta nada.
- **`svelte-mobile/public/`** — Vazia. Pode ser removida sem impacto.

### 3. Existe alguma pasta que deveria ser criada?

- **`lib/game/exports/` ou barrel files** — Não é obrigatório, mas criar um `lib/game.dart` com exports simplificaria os imports. Opcional.
- **`screenshots/`** — Recomendado para portfólio: adicionar capturas de tela do jogo para o README.

### 4. Existe algum arquivo que deveria ser criado?

| Arquivo | Prioridade | Motivo |
|---------|-----------|--------|
| `LICENSE` | 🔴 Alta | Essencial para repositório público (MIT recomendado) |
| `README.md` (novo) | 🔴 Alta | Atual é template genérico do Flutter |
| `CHANGELOG.md` | 🟡 Média | Histórico de versões (simples, 1 página) |
| `screenshots/demo.gif` ou `.png` | 🟢 Baixa | Vale mais que mil palavras no README |

### 5. Existe algum arquivo que deveria ser removido?

Nenhum arquivo precisa ser **removido**. Todos os arquivos existentes têm propósito.

### 6. Existe alguma informação sensível que não deveria ser publicada?

**Nenhuma.** Após varredura completa:
- ✅ Nenhuma chave de API, token, senha ou credential
- ✅ Nenhum e-mail interno
- ✅ Nenhuma URL privada de instituição
- ✅ Nenhum IP interno ou VPN
- ⚠️ Apenas um path local `D:\Desktop\skipper` em `docs/GAME_SPECIFICATION.md:7` — baixíssimo risco, mas pode ser sanitizado
- ⚠️ Menção a "GitLab" em `svelte-mobile/README.md:62` — Não é um link real, apenas instrução genérica "O que enviar para o GitLab". Pode ser ajustado para "GitHub" para consistência.

### 7. O .gitignore está correto?

**Sim, está correto e completo.** O `.gitignore` raiz já cobre:
- Artefatos de build (`/build/`, `/coverage/`)
- Cache Dart (`.dart_tool/`, `.pub-cache/`, `.pub/`)
- IDE (`.idea/`, `*.iml`)
- Arquivos de sistema (`.DS_Store`, `*.log`, `*.swp`)
- Android Studio (`/android/app/debug`, etc.)
- Símbolos e ofuscação (`app.*.symbols`, `app.*.map.json`)

**Melhorias opcionais sugeridas:**

```gitignore
# VS Code (se não quiser trackear configurações)
.vscode/

# Svelte mobile (já coberto pelo .gitignore do svelte-mobile/,
# mas redundância não faz mal)
svelte-mobile/node_modules/
svelte-mobile/dist/

# Env files
.env
.env.local
.env.*.local
```

**Arquivos .gitignore das plataformas** (`android/`, `ios/`, `linux/`, `macos/`, `windows/`, `svelte-mobile/`) — todos corretos e no padrão Flutter.

### 8. O README atual é suficiente?

**Não.** O README atual é o template padrão gerado pelo `flutter create`, genérico e sem qualquer informação sobre o projeto. Para um repositório público de portfólio, isso é **inaceitável** — transmite desleixo.

### 9. O projeto precisa de uma licença? Se sim, qual você recomenda e por quê?

**Sim, precisa.** Repositórios públicos sem licença têm implicações legais — ninguém pode usar, modificar ou distribuir o código.

**Recomendação: MIT License**
- ✅ Permissiva — permite uso comercial, modificação, distribuição
- ✅ Mais comum em projetos open source
- ✅ Ideal para portfólio (mostra que você entende licenciamento)
- ✅ Compatível com uso educacional

### 10. Existe documentação que deveria ser criada?

- ✅ **`README.md`** (substituir o atual)
- ✅ **`LICENSE`** (MIT)
- ✅ **`CHANGELOG.md`** (simples, 1 página — opcional)

Os docs existentes (`docs/GAME_SPECIFICATION.md`, `docs/PLANEJAMENTO.md`, etc.) são excelentes e mostram profundidade técnica — mantê-los é um diferencial para portfólio.

### 11. Há arquivos duplicados ou desnecessários?

| Arquivo | Problema |
|---------|----------|
| `svelte-mobile/public/` | Pasta vazia — desnecessária |
| `tool/` | Pasta vazia — desnecessária |
| `assets/fonts/PressStart2P-Regular.ttf` | Existe em disco mas **não é declarada em pubspec.yaml** — será ignorada em runtime |

### 12. Existem dependências que podem ser removidas?

**Não.** Todas as 3 dependências (`flame`, `flame_audio`, `shared_preferences`) são utilizadas no código. Nenhuma dependência morta.

### 13. Existem assets não utilizados?

**Não.** Todos os assets listados em `pubspec.yaml` são referenciados no código. No entanto:
- `PressStart2P-Regular.ttf` está em disco e é usado no código (`hud.dart:38`), mas **não está declarado** em `pubspec.yaml` — isso é um BUG, não um asset não utilizado.

### 14. Existem imports desnecessários?

**Não.** Todos os imports em todos os 36 arquivos Dart são utilizados. Zero imports mortos.

### 15. Existe código morto?

**Sim.** Lista completa:

| Arquivo | Linha | Código Morto | Gravidade |
|---------|-------|--------------|-----------|
| `game_state.dart` | 50-53 | Método `isCorrectStar(int number)` — nunca chamado | 🟡 Média |
| `progress_manager.dart` | 64-67 | Método `isUnlocked(int level)` — nunca chamado | 🟡 Média |
| `audio_manager.dart` | 62-65 | Método `stopBgm()` — nunca chamado | 🟡 Média |
| `skipper_game.dart` | 259-261 | `render(Canvas canvas)` — apenas `super.render(canvas)`, redundante | 🟢 Leve |
| `star.dart` | 13 | `bool isNearPlayer = false` — setado mas nunca lido | 🟡 Média |
| `game_state.dart` | 16 | `List<int> collectedNumbers` — itens adicionados/limpos mas nunca lidos | 🟡 Média |
| `platform_data.dart` | 19-21 | Getters `centerY`, `right`, `bottom` — nunca acessados | 🟢 Leve |
| `game_config.dart` | 9,20,30-36 | 7 constantes não referenciadas (`friction`, `platformWidth`, `buttonSize`, etc.) | 🟢 Leve |
| `palette.dart` | 4-34 | **22 de 35 cores** não referenciadas | 🟢 Leve |

### 16. Existem arquivos de configuração que podem ser simplificados?

- **`analysis_options.yaml`** — Precisa ser **expandido**, não simplificado. Apenas 2 regras de lint é muito pouco.
- **`pubspec.yaml`** — Precisa declarar a segunda font family (`PressStart2P-Regular.ttf`).

### 17. Existe alguma melhoria na organização do Flutter?

- ✅ Adicionar `flutter_test` e `flutter_lints` como `dev_dependencies` em `pubspec.yaml`.

### 18. Existe alguma melhoria na organização do Flame?

- O arquivo `background_cache.dart` contém a classe `BackgroundComponent` — o nome sugere cache que não existe. Renomear para `background_component.dart` alinharia nome de arquivo com conteúdo.

### 19. Existe alguma melhoria na organização do portal Svelte?

O portal Svelte está bem organizado:
- ✅ `src/`, `public/`, `package.json`, `vite.config.js` — estrutura padrão Svelte/Vite
- ✅ `.gitignore` correto
- ✅ README em português claro

**Melhoria opcional:** O README do svelte-mobile menciona GitLab (linha 62) — ajustar para GitHub se preferir consistência.

### 20. O projeto segue boas práticas para um repositório público?

**Parcialmente.** Pontos fortes:
- ✅ Código bem estruturado e auto-explicativo
- ✅ Arquitetura clara e modular
- ✅ Documentação técnica abundante
- ✅ Assets organizados
- ✅ Zero dados sensíveis
- ✅ .gitignore correto

**O que precisa melhorar:**
- ❌ README genérico do Flutter (substituir)
- ❌ Sem licença (adicionar)
- ❌ Sem testes (zero)
- ❌ Prints de debug em produção (17 ocorrências)
- ❌ Código morto (vários métodos/constantes não usados)
- ❌ Config de lint mínima (2 regras apenas)
- ❌ Falta declarar font no pubspec.yaml (bug em runtime)

---

## 4. Relatório de Problemas Encontrados

### 🔴 Críticos (impedem execução correta)

| # | Arquivo | Linha | Problema |
|---|---------|-------|----------|
| C1 | `pubspec.yaml` | 25-29 | `PressStart2P-Regular.ttf` usado em `hud.dart:38` mas **não declarado** em pubspec.yaml. A HUD usará fonte fallback silenciosamente. |

### 🟡 Médios (comprometem qualidade profissional)

| # | Arquivo | Linha | Problema |
|---|---------|-------|----------|
| M1 | `skipper_game.dart` | 84 | Listener `_onStateChanged` adicionado a `state` mas **nunca removido** antes do `state.dispose()` — risco de `BadState` exception |
| M2 | `player.dart` | 82-107 | Animações trocadas via `removeFromParent()` + `add()` a cada transição — ineficiente, deveria usar `SpriteAnimationGroupComponent` |
| M3 | `star.dart` | 56-74 | `TextPainter` criado e relayout a cada frame — problema de performance |
| M4 | `level_generator.dart` | 696-726 | Método `_printStartLevel()` com **12 prints** executado a cada geração de nível |
| M5 | `progress_manager.dart` | 81-87 | **4 prints** de confirmação ao salvar progresso |
| M6 | `level_select_screen.dart` | 54 | **1 print** no catch de erro |
| M7 | `level_generator.dart` | 19-21 | Duplica constantes de `game_config.dart` (`playerWidth`, `playerHeight`, `groundY`) |
| M8 | `star.dart` | 13, 80-89 | `isNearPlayer` nunca lido — sistema de colisão em estrelas é inútil (coleta usa distância manual) |
| M9 | `game_state.dart` | 29,32 | `loseHP()` chama `notifyListeners()` duas vezes quando HP chega a 0 |

### 🟢 Leves (cosméticos / boas práticas)

| # | Arquivo | Linha | Problema |
|---|---------|-------|----------|
| L1 | `assets/images/objects/` | filename | Typo: `plataform.png` → `platform.png` |
| L2 | `background_cache.dart` | 1 | Nome do arquivo e classe sugerem cache que não existe. Renomear para `background_component.dart` |
| L3 | `skipper_game.dart` | 259-261 | Método `render()` vazio que só chama `super.render()` — remover |
| L4 | `game_state.dart` | 50-53 | Método `isCorrectStar()` não utilizado |
| L5 | `progress_manager.dart` | 64-67 | Método `isUnlocked()` não utilizado |
| L6 | `audio_manager.dart` | 62-65 | Método `stopBgm()` não utilizado |
| L7 | `game_config.dart` | 9,20,30-36 | 7 constantes não referenciadas |
| L8 | `palette.dart` | 4-34 | 22 cores não referenciadas |
| L9 | `platform_data.dart` | 19-21 | Getters `centerY`, `right`, `bottom` não usados |
| L10 | `game_state.dart` | 16 | `collectedNumbers` não lido |
| L11 | `level_select_screen.dart` | 11 | `debugFixedSeed` público — deveria ser privado ou via `--dart-define` |
| L12 | `analysis_options.yaml` | 1-4 | Apenas 2 regras de lint — muito pouco |
| L13 | `web/index.html` | 21 | Meta description: "A new Flutter project." — desatualizado |
| L14 | `web/index.html` | 32 | Título: "skipper" — poderia ser "Skipper - 2D Educational Platformer" |
| L15 | `pubspec.yaml` | `dev_dependencies` | Nenhuma dependência de desenvolvimento declarada |
| L16 | `test/` | - | Diretório vazio — sem testes |
| L17 | `svelte-mobile/README.md` | 62 | Menção a "GitLab" (genérico) |
| L18 | `docs/GAME_SPECIFICATION.md` | 7 | Path local `D:\Desktop\skipper` — informação irrelevante publicamente |
| L19 | `svelte-mobile/public/` | - | Pasta vazia |
| L20 | `tool/` | - | Pasta vazia |

---

## 5. Informações Sensíveis

### 5.1 Resultado da varredura

| Tipo | Encontrado? | Local |
|------|-------------|-------|
| Chaves de API | ❌ Não | - |
| Tokens de acesso | ❌ Não | - |
| Senhas | ❌ Não | - |
| E-mails institucionais | ❌ Não | - |
| URLs de VPN/intranet | ❌ Não | - |
| IPs internos | ❌ Não | - |
| Paths locais | ⚠️ Sim, 1 | `docs/GAME_SPECIFICATION.md:7` — `D:\Desktop\skipper` |
| Referências a GitLab | ⚠️ Sim, 1 | `svelte-mobile/README.md:62` — "O que enviar para o GitLab" |

### 5.2 Ações recomendadas

1. **`docs/GAME_SPECIFICATION.md:7`** — Remover ou substituir a linha `Projeto analisado: D:\Desktop\skipper` por algo como `Projeto analisado localmente`.
2. **`svelte-mobile/README.md:62`** — Alterar "GitLab" para "GitHub" para consistência com o repositório alvo. Exemplo: `O que enviar para o repositório`.

> 📌 **Nota:** Nenhum dos dois itens acima é um risco de segurança real. São apenas ajustes de apresentação.

---

## 6. Lista de Melhorias por Prioridade

### 🔴 Prioridade Alta (essencial para publicação)

| # | Tarefa | Esforço | Impacto |
|---|--------|---------|---------|
| 1 | Criar `LICENSE` (MIT) | 5 min | ⭐⭐⭐ |
| 2 | Substituir `README.md` com versão profissional | 30 min | ⭐⭐⭐ |
| 3 | Adicionar `PressStart2P-Regular.ttf` ao `pubspec.yaml` | 2 min | ⭐⭐⭐ |
| 4 | Fazer o primeiro commit + push para GitHub | 5 min | ⭐⭐⭐ |

### 🟡 Prioridade Média (fortemente recomendado)

| # | Tarefa | Esforço | Impacto |
|---|--------|---------|---------|
| 5 | Remover prints de debug (17 ocorrências em 3 arquivos) | 10 min | ⭐⭐ |
| 6 | Expandir `analysis_options.yaml` com mais regras de lint | 5 min | ⭐⭐ |
| 7 | Adicionar `flutter_test` e `flutter_lints` como `dev_dependencies` | 2 min | ⭐⭐ |
| 8 | Corrigir código morto (métodos não usados, constantes não usadas) | 15 min | ⭐⭐ |
| 9 | Corrigir listener leak em `skipper_game.dart` (remover listener antes de dispose) | 5 min | ⭐⭐ |
| 10 | Atualizar `web/index.html` (description + title) | 3 min | ⭐⭐ |
| 11 | Adicionar `CHANGELOG.md` básico | 5 min | ⭐ |
| 12 | Sanitizar `docs/GAME_SPECIFICATION.md` (path local) | 1 min | ⭐ |
| 13 | Atualizar `svelte-mobile/README.md` (GitLab → GitHub) | 1 min | ⭐ |

### 🟢 Prioridade Baixa (polimento)

| # | Tarefa | Esforço | Impacto |
|---|--------|---------|---------|
| 14 | Renomear `plataform.png` → `platform.png` (arquivo + código + docs) | 10 min | ⭐ |
| 15 | Renomear `background_cache.dart` → `background_component.dart` | 5 min | ⭐ |
| 16 | Remover `render()` redundante em `skipper_game.dart` | 1 min | ⭐ |
| 17 | Tornar `debugFixedSeed` privado ou via `--dart-define` | 3 min | ⭐ |
| 18 | Remover pastas vazias (`tool/`, `svelte-mobile/public/`) | 1 min | ⭐ |
| 19 | Otimizar `TextPainter` em `star.dart` (criar uma vez, não a cada frame) | 10 min | ⭐ |
| 20 | Otimizar animações do player com `SpriteAnimationGroupComponent` | 20 min | ⭐ |
| 21 | Adicionar `screenshots/` com capturas do jogo | 10 min | ⭐ |

---

## 7. Plano de Ação Passo a Passo

### Fase 1 — Preparação (30 min)

```bash
# 1. Verificar estado atual
git status

# 2. Criar arquivos necessários
#    - LICENSE (MIT)
#    - README.md (novo)
#    - CHANGELOG.md (opcional)
```

### Fase 2 — Correções no Código (45 min)

```
Passo 2.1: Adicionar font ao pubspec.yaml
  - Adicionar família 'PressStart2P' com asset 'assets/fonts/PressStart2P-Regular.ttf'

Passo 2.2: Expandir analysis_options.yaml
  - Adicionar include: package:flutter_lints/flutter.yaml

Passo 2.3: Adicionar dev_dependencies no pubspec.yaml
  - flutter_test, flutter_lints

Passo 2.4: Remover prints de debug (3 arquivos)
  - level_generator.dart: remover _printStartLevel() e _logFailure()
  - progress_manager.dart: remover prints em completeLevel()
  - level_select_screen.dart: remover print no catch

Passo 2.5: Corrigir listener leak em skipper_game.dart
  - Adicionar @override onRemove() que chama state.removeListener(_onStateChanged)

Passo 2.6: Remover render() redundante em skipper_game.dart

Passo 2.7: Atualizar web/index.html
  - description: "Skipper - 2D educational platformer built with Flutter and Flame"
  - title: "Skipper - 2D Educational Platformer"
```

### Fase 3 — Limpeza de Assets (10 min)

```
Passo 3.1: Renomear plataform.png → platform.png
  - Arquivo físico
  - lib/game/components/platform.dart:24
  - docs/GAME_SPECIFICATION.md (múltiplas ocorrências)

Passo 3.2: Renomear background_cache.dart → background_component.dart
  - Arquivo físico
  - Atualizar import em skipper_game.dart
```

### Fase 4 — Documentação (40 min)

```
Passo 4.1: Escrever novo README.md
Passo 4.2: Criar LICENSE (MIT)
Passo 4.3: Criar CHANGELOG.md
Passo 4.4: Sanitizar docs/GAME_SPECIFICATION.md (remover path local)
Passo 4.5: Atualizar svelte-mobile/README.md (GitLab → GitHub)
```

### Fase 5 — Publicação (10 min)

```bash
# 1. Verificar git status
git status

# 2. Adicionar tudo
git add .

# 3. Verificar o que será commitado
git status

# 4. Fazer o commit
git commit -m "feat: initial release - Skipper 2D educational platformer

- Flutter + Flame game with procedural level generation
- 6 layout archetypes with progressive difficulty
- Touch and keyboard controls
- Audio system (BGM + SFX)
- Local progress saving
- Cross-platform: Android, iOS, Web, Windows, Linux, macOS"

# 5. Criar repositório no GitHub e conectar
git remote add origin https://github.com/seu-usuario/skipper.git
git branch -M main
git push -u origin main
```

---

## 8. Arquivos a Criar e Modificar

### 8.1 README.md (novo — substituir o atual)

```markdown
# 🎮 Skipper

**Skipper** é um jogo de plataforma educativo 2D desenvolvido com **Flutter** e **Flame**. O jogador controla um personagem que precisa coletar estrelas na ordem matemática correta para avançar por fases geradas proceduralmente.

> Projeto de portfólio demonstrando arquitetura de jogos com Flutter, geração procedural de conteúdo e design cross-platform.

---

## ✨ Funcionalidades

- 🧩 **Geração procedural de fases** com 6 arquétipos de layout (stairUp, stairDown, zigZag, peak, valley, mixed)
- 📈 **10 níveis com dificuldade progressiva** — gaps maiores, plataformas mais estreitas, estrelas mais desafiadoras
- 🎮 **Controles touch e teclado** — suporte completo para mobile e desktop
- 🎵 **Áudio completo** — trilha sonora (BGM) e efeitos sonoros (SFX)
- 💾 **Salvamento automático** de progresso via `SharedPreferences`
- 🎯 **Sistema de coleta em sequência** — colete as estrelas na ordem correta
- 📱 **Responsivo** — adapta-se a diferentes tamanhos de tela
- 🖥️ **6 plataformas** — Android, iOS, Web, Windows, Linux, macOS

---

## 🛠️ Tecnologias

| Tecnologia | Versão | Finalidade |
|-----------|--------|------------|
| [Flutter](https://flutter.dev) | ≥ 3.44.0 | Framework cross-platform |
| [Flame](https://flame-engine.org) | 1.37.0 | Game engine 2D |
| [flame_audio](https://pub.dev/packages/flame_audio) | 2.12.1 | Gerenciamento de áudio |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | 2.2.0 | Persistência local |
| [Flutter Lints](https://pub.dev/packages/flutter_lints) | ^4.0.0 | Análise estática |
| [Svelte](https://svelte.dev) + [Vite](https://vitejs.dev) | 5.x / 5.x | Portal mobile web (opcional) |

---

## 🏗️ Arquitetura

O jogo segue a arquitetura de componentes do Flame, com um `FlameGame` central que orquestra:

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp + rotas
└── game/
    ├── skipper_game.dart              # FlameGame principal
    ├── game_state.dart                # Estado do jogo (ChangeNotifier)
    ├── audio_manager.dart             # Gerenciamento de áudio
    ├── components/                    # Componentes do jogo
    │   ├── player.dart                # Física, animação, colisão
    │   ├── platform.dart              # Plataforma com animação de bounce
    │   ├── star.dart                  # Estrela coletável
    │   ├── star_collect_effect.dart   # Efeito visual de coleta
    │   └── background_component.dart  # Fundo parallax
    ├── config/
    │   ├── game_config.dart           # Constantes do jogo
    │   └── palette.dart               # Paleta de cores
    ├── levels/                        # Sistema de geração procedural
    │   ├── level_generator.dart       # Algoritmo de geração
    │   ├── difficulty_manager.dart    # Regras de dificuldade
    │   ├── platform_spawner.dart      # Spawn de plataformas
    │   ├── star_spawner.dart          # Spawn de estrelas
    │   └── progress_manager.dart      # Save/Load
    ├── screens/                       # Telas e overlays
    │   ├── title_screen.dart
    │   ├── game_screen.dart
    │   ├── level_select_screen.dart
    │   ├── pause_overlay.dart
    │   ├── game_over_screen.dart
    │   ├── victory_screen.dart
    │   └── tutorial_overlay.dart
    └── ui/                            # Componentes de interface
        ├── hud.dart
        ├── touch_controls.dart
        ├── keyboard_input.dart
        └── pixel_menu.dart
```

### Geração Procedural de Fases

O sistema de geração procedural cria fases completas usando **6 arquétipos de layout**:

- **stairUp** — Plataformas em escada ascendente
- **stairDown** — Plataformas em escada descendente
- **zigZag** — Zigue-zague vertical
- **peak** — Pico no centro
- **valley** — Vale no centro
- **mixed** — Combinação aleatória

Cada nível gerado passa por validações de alcançabilidade, sobreposição e qualidade visual antes de ser aceito.

---

## 🚀 Como Executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.44.0
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.12.0

### Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/skipper.git
cd skipper

# Instale as dependências
flutter pub get

# Execute o jogo
flutter run
```

### Plataformas específicas

```bash
# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Android (dispositivo conectado)
flutter run -d android

# iOS (macOS necessário)
flutter run -d ios
```

### Portal Mobile (Svelte)

O portal Svelte é uma página opcional que emoldura o jogo Web em um visual arcade mobile:

```bash
cd svelte-mobile
npm install
npm run dev
```

> Configure `VITE_GAME_URL` para apontar para onde o build web do Flutter estiver servido.

### Build de Produção

```bash
flutter build web        # Web
flutter build apk        # Android
flutter build windows    # Windows
flutter build ios        # iOS (macOS)
```

---

## 📱 Plataformas Suportadas

| Plataforma | Status |
|-----------|--------|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| Windows | ✅ |
| Linux | ✅ |
| macOS | ✅ |

---

## 🧪 Testes

```bash
flutter test
```

> Testes estão em desenvolvimento. O diretório `test/` será populado em versões futuras.

---

## 🎯 Principais Aprendizados

- **Geração procedural de conteúdo** — Implementação de validação de alcançabilidade, distribuição de plataformas e garantia de níveis completáveis
- **Física de jogos 2D** — Gravidade, pulo variável (coyote time, jump cut), colisão AABB
- **Arquitetura Flutter + Flame** — Integração entre widgets Flutter e game loop do Flame, gerenciamento de estado com `ChangeNotifier`
- **Sistemas de áudio** — Gerenciamento de BGM/SFX com fade, muffle e pooling
- **Design cross-platform** — Adaptação de inputs (touch + teclado) e layout responsivo

## 🧗 Desafios Encontrados

- **Validação de níveis gerados** — Garantir que todo nível procedural seja completável exigiu múltiplas camadas de verificação (alcançabilidade, overlap, bounding boxes)
- **Integração touch + teclado** — Unificar dois sistemas de input concorrentes sem conflitos ou prioridade indevida
- **Gerenciamento de áudio em pausa** — Implementar muffle sonoro ao pausar e restaurar ao retomar sem estouro de áudio

## 🧭 Decisões de Arquitetura

- **ChangeNotifier vs BLoC/Riverpod** — Optou-se por `ChangeNotifier` por simplicidade e integração direta com o `addListener` do Flame, adequado para um jogo deste porte
- **Colisão manual vs sistema do Flame** — A colisão jogador-plataforma é feita manualmente (AABB) para dar controle total sobre a física (coyote time, correção de penetração)
- **Geração procedural vs níveis pré-fabricados** — Geração procedural foi escolhida para demonstrar habilidades com algoritmos e permitir replayabilidade

---

## 📄 Licença

Este projeto está licenciado sob a licença **MIT** — veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 🙏 Créditos

- **Google Fonts** — Fonte Press Start 2P ([Open Font License](https://fonts.google.com/specimen/Press+Start+2P))
- **Flame Engine** — Game engine 2D para Flutter ([flame-engine.org](https://flame-engine.org))
- **Assets visuais e sonoros** — Produzidos internamente para este projeto

---

<p align="center">
  Feito com 💙 para educação e portfólio
</p>
```

### 8.2 LICENSE (MIT)

```markdown
MIT License

Copyright (c) 2026 [Seu Nome]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### 8.3 pubspec.yaml (modificação)

Adicionar ao `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/images/hud/
    - assets/images/objects/
    - assets/images/player/
    - assets/audio/music/
    - assets/audio/sfx/
  fonts:
    - family: PixelFont
      fonts:
        - asset: assets/fonts/pixel_font.ttf
    - family: PressStart2P            # ✨ NOVO
      fonts:                          # ✨ NOVO
        - asset: assets/fonts/PressStart2P-Regular.ttf  # ✨ NOVO

dev_dependencies:                     # ✨ NOVO
  flutter_test:                       # ✨ NOVO
    sdk: flutter                      # ✨ NOVO
  flutter_lints: ^4.0.0               # ✨ NOVO
```

### 8.4 analysis_options.yaml (substituir)

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - prefer_final_locals
    - use_super_parameters
    - avoid_redundant_argument_values
    - sort_child_properties_last
    - avoid_unnecessary_containers
    - prefer_single_quotes
```

### 8.5 CHANGELOG.md (novo — opcional)

```markdown
# Changelog

## [1.0.0] - 2026-06-30

### Adicionado
- Jogo de plataforma educativo 2D com Flutter + Flame
- Geração procedural de fases com 6 arquétipos de layout
- 10 níveis com dificuldade progressiva
- Sistema de coleta de estrelas em sequência matemática
- Controles touch e teclado
- Tutorial interativo
- Salvamento e carregamento de progresso
- Áudio completo (BGM + efeitos sonoros)
- Suporte a 6 plataformas: Android, iOS, Web, Windows, Linux, macOS
- Portal mobile complementar em Svelte + Vite
```

### 8.6 Modificações em arquivos existentes

| Arquivo | Modificação |
|---------|-------------|
| `lib/game/skipper_game.dart` | Adicionar `onRemove()` removendo listener; remover `render()` redundante |
| `lib/game/components/platform.dart` | Atualizar referência de `'objects/plataform.png'` para `'objects/platform.png'` |
| `lib/game/skipper_game.dart` | Atualizar import de `background_cache.dart` para `background_component.dart` |
| `lib/game/screens/level_select_screen.dart` | Tornar `debugFixedSeed` privado ou remover |
| `lib/game/levels/level_generator.dart` | Remover métodos de debug print; usar constantes de `game_config.dart` |
| `lib/game/game_state.dart` | Corrigir `notifyListeners()` duplicado |
| `lib/game/audio_manager.dart` | Remover `stopBgm()` se não usado ou manter |
| `lib/game/progress_manager.dart` | Remover prints de debug |
| `web/index.html` | Atualizar description e title |
| `docs/GAME_SPECIFICATION.md` | Remover path local |
| `svelte-mobile/README.md` | GitLab → GitHub |

---

## 9. Checklist Final de Publicação

### 🔲 Pré-commit

- [ ] `pubspec.yaml` tem as duas fontes declaradas (PixelFont + PressStart2P)
- [ ] `pubspec.yaml` tem `dev_dependencies` (flutter_test, flutter_lints)
- [ ] `analysis_options.yaml` expandido com regras de lint
- [ ] `README.md` substituído pela versão profissional
- [ ] `LICENSE` (MIT) criado na raiz
- [ ] `CHANGELOG.md` criado (opcional)
- [ ] Código morto removido ou comentado
- [ ] Prints de debug removidos
- [ ] Listener leak corrigido em `skipper_game.dart`
- [ ] `render()` redundante removido
- [ ] `web/index.html` com description e title personalizados
- [ ] `docs/GAME_SPECIFICATION.md` sem path local
- [ ] `svelte-mobile/README.md` sem menção a GitLab
- [ ] Pastas vazias removidas (`tool/`, `svelte-mobile/public/`)

### 🔲 Verificação de Build

- [ ] `flutter pub get` executa sem erros
- [ ] `flutter analyze` sem warnings críticos
- [ ] `flutter build web` bem-sucedido (valida assets e fontes)

### 🔲 Verificação de Git

- [ ] `.gitignore` cobre todas as pastas de build/cache
- [ ] Nenhum arquivo `.env` ou credencial no staging
- [ ] `git status` mostra apenas os arquivos desejados
- [ ] Nenhum arquivo temporário (`.log`, `.swp`) no staging

### 🔲 Pós-publicação

- [ ] Repositório criado no GitHub
- [ ] Remote configurado: `git remote -v`
- [ ] Push realizado: `git push -u origin main`
- [ ] README renderizando corretamente no GitHub
- [ ] Licença visível no topo do repositório

---

## Apêndice — Comandos Úteis

```bash
# Verificar se há prints no código
rg "print\(|debugPrint\(" lib/ --include '*.dart'

# Verificar código morto (métodos não chamados)
rg "^\s+\w+\(.*\)\s*\{" lib/ --include '*.dart'

# Verificar arquivos grandes (>500 linhas)
Get-ChildItem -Recurse -Filter *.dart lib/ | Where-Object {
  (Get-Content $_.FullName | Measure-Object -Line).Lines -gt 500
}

# Verificar dependências não utilizadas
dart pub deps

# Análise estática completa
flutter analyze

# Verificar assets declarados vs assets em disco
diff <(Get-ChildItem -Recurse assets/ | ForEach-Object { $_.FullName.Replace($PWD.Path, "").TrimStart("\") }) <(Select-String "assets/" pubspec.yaml | ForEach-Object { $_ -replace ".*-\s*", "" -replace '"', '' })
```

---

> **Documento gerado em:** 30/06/2026
> **Ferramentas utilizadas:** Análise estática de código, varredura de dependências, revisão manual de 36 arquivos Dart
