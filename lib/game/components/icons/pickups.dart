import 'package:first_app_flutter/game/components/player.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/iso_body.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Item lying on the ground. Picked up when the hero walks on it.
class Pickup extends SpriteComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks, IsoBody {
  Pickup(Vector2 startGround, this.imagePath, {this.onPicked})
      : super(size: Vector2.all(32), anchor: const Anchor(0.5, 0.9)) {
    ground.setFrom(startGround);
  }

  final String imagePath;
  final void Function(SurvivalGame game)? onPicked;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache(imagePath));
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    syncIso();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (!game.canProcessInput() || other is! Player) return;
    onPicked?.call(game);
    removeFromParent();
  }
}

/// Quiver: refills arrows.
class GunIcon extends Pickup {
  GunIcon(Vector2 ground)
      : super(ground, 'iso/arrow_pickup.png', onPicked: (g) => g.bullets = 50);
}
