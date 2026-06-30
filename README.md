# Skipper

**Skipper** é um jogo de plataforma educativo 2D desenvolvido com Flutter e Flame. O jogador coleta estrelas na ordem matemática correta para avançar por fases geradas proceduralmente.

## Tecnologias

- **Flutter** ≥ 3.44.0 — Framework cross-platform
- **Flame** 1.37.0 — Game engine 2D
- **flame_audio** — Gerenciamento de áudio
- **shared_preferences** — Persistência local
- **Svelte 5 + Vite 5** — Portal mobile web (opcional)

## Funcionalidades

- Geração procedural de fases com 6 arquétipos de layout
- 10 níveis com dificuldade progressiva
- Controles touch e teclado
- Áudio completo (BGM + SFX)
- Salvamento automático de progresso
- Tutorial interativo
- Suporte a 6 plataformas

## Estrutura

```
lib/
├── main.dart
├── app.dart
└── game/
    ├── skipper_game.dart          # Game loop principal
    ├── game_state.dart            # Estado do jogo
    ├── audio_manager.dart         # Áudio
    ├── components/                # Player, plataforma, estrelas, efeitos
    ├── config/                    # Constantes e paleta
    ├── levels/                    # Geração procedural, dificuldade, progresso
    ├── screens/                   # Telas (título, jogo, seleção, overlays)
    └── ui/                        # HUD, controles, menu
```

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.44.0
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.12.0

## Instalação

```bash
git clone https://github.com/seu-usuario/skipper.git
cd skipper
flutter pub get
```

## Execução

```bash
flutter run                    # Plataforma padrão
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d android         # Android
```

### Portal Mobile (Svelte)

```bash
cd svelte-mobile
npm install
npm run dev
```

## Plataformas

Android · iOS · Web · Windows · Linux · macOS

## Licença

MIT © 2026 — Veja o arquivo [LICENSE](LICENSE).
