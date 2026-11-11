import 'dart:math' as math;

import 'package:first_app_flutter/game/components/player.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:first_app_flutter/game/iso/iso_body.dart';
import 'package:first_app_flutter/game/utils/AudioManager.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Arrow (image 16x4 pointing right), flying at chest height.
class Bullet extends SpriteComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks, IsoBody {
  Bullet(Vector2 startGround, Vector2 groundDir)
      : _dir = groundDir.normalized(),
        _start = startGround.clone(),
        super(size: Vector2(16, 4), anchor: Anchor.center) {
    ground.setFrom(startGround);
    elevation = 20;
    final s = Iso.deltaToScreen(_dir);
    angle = math.atan2(s.y, s.x);
  }

  final Vector2 _dir;
  final Vector2 _start;

  /// Ground units per second.
  static const _speed = 260.0;
  static const _range = 320.0;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('iso/arrow.png'));
    AudioManager().playPanSound();
    add(RectangleHitbox()..collisionType = CollisionType.active);
    syncIso();
  }

  @override
  void update(double dt) {
    super.update(dt);
    ground.add(_dir * _speed * dt);
    syncIso();
    if (ground.distanceTo(_start) > _range) removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is! Player) removeFromParent();
  }
}
