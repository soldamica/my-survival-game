import 'package:first_app_flutter/game/components/bullet.dart';
import 'package:first_app_flutter/game/components/player.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/character_sheet.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:first_app_flutter/game/iso/iso_body.dart';
import 'package:first_app_flutter/game/utils/AudioManager.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Zombie walking straight to the hero on the ground plane (8 directions).
class Zombie extends SpriteAnimationComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks, IsoBody {
  Zombie(this.name, Vector2 startGround, this.sheet)
      : super(
          size: Vector2.all(CharacterSheet.frame),
          anchor: const Anchor(0.5, 44 / 48),
        ) {
    ground.setFrom(startGround);
  }

  final String name;
  final CharacterSheet sheet;
  bool isReallyDead = false;
  bool isfocus = true;

  /// Ground units per second.
  static const _speed = 32.0;
  int _row = 0;
  late final Sprite _shadow;

  @override
  Future<void> onLoad() async {
    AudioManager().playZombieSound();
    animation = sheet.row(_row);
    _shadow = Sprite(game.images.fromCache('iso/shadow.png'));
    add(RectangleHitbox(position: Vector2(16, 18), size: Vector2(16, 26)));
    syncIso();
  }

  @override
  void render(Canvas canvas) {
    renderShadow(canvas, _shadow);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (game.endOfGame) return;
    super.update(dt);
    if (isfocus) {
      final toPlayer = game.playerGround - ground;
      if (toPlayer.length2 > 1) {
        final dir = toPlayer.normalized();
        ground.add(dir * _speed * dt);
        final row = Iso.dirRow(Iso.deltaToScreen(dir), _row);
        if (row != _row) {
          _row = row;
          animation = sheet.row(row);
        }
      }
    }
    syncIso();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (isReallyDead) return;

    if (other is Bullet) {
      isReallyDead = true;
      removeFromParent();
      AudioManager().playExplosedSound();
      game.score++;
      game.evalNextWave();
      return;
    }

    if (other is Player && !other.isDead) {
      isfocus = false;
      other.isDead = true;
      game.finishGame(other.position);
    }
  }
}
