# AGENTS.md

## Overview
Flutter zombie survival game built with the Flame engine.
Targets: Linux, Android, iOS, Web, macOS, Windows.

## Tech Stack
- Flutter / Dart SDK `>=2.18.2 <3.0.0`
- Flame `^1.19.0` (game engine)
- flame_audio `^2.10.3` (sound)
- google_fonts `^5.1.0`
- Package name: `first_app_flutter`
- Android application id: `com.micael.zombie`

## Project Structure
- `lib/main.dart` — app entry point
- `lib/title_screen.dart` — title screen
- `lib/game/game.dart` — main Flame game class
- `lib/game/game_page.dart` — page hosting the game widget
- `lib/game/RightPanel.dart` — side UI panel
- `lib/game/components/` — game components
  - `player.dart`, `bullet.dart`, `background.dart`, `game_over_overlay.dart`
  - `monsters/`, `weapons/`, `animations/`, `icons/`
  - `components.dart` — barrel export file
- `lib/game/utils/` — utilities
  - `AudioManager.dart` — centralized audio playback
  - `heroes_sprite_preloader.dart`, `zombie_sprite_preloader.dart` — sprite preloading
- `assets/images/`, `assets/audio/` — game assets (declared in `pubspec.yaml`)
- `test/` — tests

## Commands
```bash
flutter pub get          # install dependencies
flutter run -d linux     # run on desktop
flutter analyze          # static analysis / lints
flutter test             # run tests
flutter build apk        # build Android APK
```

## Conventions
- Use snake_case for new file names. Existing exceptions (`RightPanel.dart`, `AudioManager.dart`) are kept as-is; do not rename them unless asked.
- Follow `flutter_lints` rules configured in `analysis_options.yaml`.
- Export new components through `lib/game/components/components.dart`.
- Place new assets in `assets/images/` or `assets/audio/` (folders are already declared in `pubspec.yaml`).
- Play sound effects through `AudioManager` (add a method there for new sounds); background music uses `FlameAudio.bgm`.
- Preload sprites via the `*_sprite_preloader.dart` utilities rather than loading them ad hoc.

## Agent Rules
- Never edit generated or build files: `build/`, `linux/flutter/ephemeral/`, `**/generated_plugin_registrant.*`, `ios/Flutter/Generated.xcconfig`, `ios/Flutter/flutter_export_environment.sh`.
- Do not change the Android package id `com.micael.zombie`.
- Do not add or upgrade dependencies without explicit approval.
- Run `flutter analyze` after every change and fix any new issues.
- Keep changes minimal and focused on the requested task.
