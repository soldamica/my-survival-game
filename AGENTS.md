# AGENTS.md

## Projet
Jeu de survie isométrique Flutter + Flame (package `first_app_flutter`).
Cibles : Linux, Android, iOS, Web, macOS, Windows.

## Stack
- Dart SDK `>=3.0.0 <4.0.0`
- Flame `^1.19.0`, flame_audio `^2.10.3`, google_fonts `^9.0.0`
- Android application id : `com.micael.zombie` (ne pas modifier)

## Commandes
```bash
flutter pub get          # dépendances
flutter run -d linux     # lancer
flutter analyze          # analyse statique
flutter test             # tests
flutter build apk        # build Android
```

## Architecture
- `lib/main.dart` : point d'entrée ; `lib/title_screen.dart` : écran titre ; `lib/dev_game.dart` : mode dev
- `lib/game/game.dart` : classe principale du jeu Flame ; `lib/game/game_page.dart` : widget hôte
- `lib/game/components/`
  - `player.dart` (héros), `bullet.dart`, `background.dart`, `game_over_overlay.dart`
  - `monsters/` : `mob.dart` (classe abstraite) + implémentations (`gobelin.dart`…)
  - `hud/` : `hud.dart` (globe rouge = PV du héros), `weapon_switch_button.dart`
  - `weapons/`, `icons/`, `animations/`
  - `components.dart` : fichier barrel d'export
- `lib/game/iso/` : rendu isométrique (`iso.dart`, `iso_body.dart`, `gothic.dart`) et `CharacterSheet`
- `lib/game/utils/AudioManager.dart` : gestion du son (singleton)
- `assets/images/`, `assets/images/iso/`, `assets/audio/` : assets déclarés dans `pubspec.yaml`

## Règles de gameplay
- Héros : 100 PV, attaque 50. Ses PV sont liés au globe rouge du HUD.
- Monstres : 100 PV par défaut, attaque 25.

## Ajouter un monstre
1. Créer une classe dans `lib/game/components/monsters/` qui étend `Mob`.
2. Déclarer `moveSprite` et `attackSprite` en `static final CharacterSheet`.
3. Implémenter `loadSprites` (statique), `sheet`, `attackSheet`, `maxHp`, `attack`, `playSpawnSound`, `playDeathSound`.
4. Appeler `loadSprites` au chargement du jeu, sinon le monstre n'apparaît pas.
5. Exporter la classe via `components.dart`.

## Conventions
- Commentaires et documentation en français.
- snake_case pour les nouveaux fichiers (exceptions existantes `AudioManager.dart`, `RightPanel.dart` : ne pas renommer).
- Respecter `flutter_lints` (`analysis_options.yaml`).
- Sons via `AudioManager` (ajouter une méthode pour tout nouveau son) ; musique via `FlameAudio.bgm`.

## Règles pour les agents
- Ne jamais modifier les fichiers générés : `build/`, `linux/flutter/ephemeral/`, `**/generated_plugin_registrant.*`, `ios/Flutter/Generated.xcconfig`, `ios/Flutter/flutter_export_environment.sh`.
- Ne pas modifier les assets de `assets/` sans demande explicite.
- Ne pas ajouter/mettre à jour de dépendances sans accord.
- Lancer `flutter analyze` après chaque modification et corriger les nouveaux problèmes.
- Changements minimaux, centrés sur la demande.

## Agents spécialisés
- **designer** (`.github/agents/designer.agent.md`) : pixel art 16-bit (SNES / « A Link to the Past »), HUD et sprites générés par code.
