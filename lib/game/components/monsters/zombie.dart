import 'package:first_app_flutter/game/components/monsters/mob.dart';
import 'package:first_app_flutter/game/iso/character_sheet.dart';
import 'package:first_app_flutter/game/utils/AudioManager.dart';
import 'package:flame/game.dart';

/// Gobelin à pique.
class Zombie extends Mob {
  Zombie(super.name, super.startGround);

  /// Sprite de mouvement.
  static final CharacterSheet moveSprite = CharacterSheet();

  /// Sprite d'attaque.
  static final CharacterSheet attackSprite =
      CharacterSheet(frames: 4, loop: false);

  /// Charge les sprites (à appeler une fois au chargement du jeu).
  static Future<void> loadSprites(FlameGame game) async {
    await moveSprite.load(game, 'gobelin_pique_marche_768.png', stepTime: 0.14);
    // 4 frames x 0.15 s = 0.6 s wind-up: time for the hero to dodge.
    await attackSprite.load(game, 'gobelin_pique_attaque_384x768.png',
        stepTime: 0.15);
  }

  @override
  CharacterSheet get sheet => moveSprite;

  @override
  CharacterSheet get attackSheet => attackSprite;

  /// Points de vie.
  @override
  double get maxHp => 100;

  /// Valeur d'attaque.
  @override
  double get attack => 25;

  @override
  void playSpawnSound() => AudioManager().playZombieSound();

  @override
  void playDeathSound() => AudioManager().playExplosedSound();
}
