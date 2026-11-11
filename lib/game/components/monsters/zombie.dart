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
          anchor: CharacterSheet.feet,
        ) {
    ground.setFrom(startGround);
  }

  final String name;
  final CharacterSheet sheet;
  bool isReallyDead = false;
  bool isfocus = true;

  /// Ground units per second.
  static const _speed = 64.0;
  int _row = 0;
  late final Sprite _shadow;

  @override
  Future<void> onLoad() async {
    AudioManager().playZombieSound();
    animation = sheet.row(_row);
    _shadow = Sprite(game.images.fromCache('iso/shadow.png'));
    // Lower body only, so overlaps look right in isometric view.
    add(RectangleHitbox(position: Vector2(34, 40), size: Vector2(28, 48)));
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

  /// Killed by an arrow or a sword hit.
  void die() {
    if (isReallyDead) return;
    isReallyDead = true;
    removeFromParent();
    AudioManager().playExplosedSound();
    game.score++;
    game.evalNextWave();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (isReallyDead) return;

    if (other is Bullet) {
      die();
      return;
    }

    if (other is Player && !other.isDead) {
      isfocus = false;
      other.isDead = true;
      game.finishGame(other.position);
    }
  }
}
