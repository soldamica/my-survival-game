import 'package:first_app_flutter/game/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:first_app_flutter/game/game.dart';

class SwordIcon extends SpriteComponent with HasGameRef<SurvivalGame>, CollisionCallbacks {
  static const _spriteSword = 'sword.png';

  SwordIcon(Vector2 position)
      : super(
    position: position,
    size: Vector2(30, 30),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Charger le sprite et l'assigner à ce composant
    sprite = await Sprite.load(_spriteSword);

    // Ajouter une hitbox ou d'autres configurations si nécessaire
    add(
      RectangleHitbox.relative(
        Vector2(0.5, 0.3),
        parentSize: size,
      )..collisionType = CollisionType.passive,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!gameRef.canProcessInput()) return;
    super.onCollision(intersectionPoints, other);
    if(other is Player){
      super.removeFromParent();
    }
  }
}
