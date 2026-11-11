import 'package:first_app_flutter/game/components/player.dart';
import 'package:first_app_flutter/game/components/pixel/pixel_art_data.dart';
import 'package:first_app_flutter/game/components/pixel/pixel_sprite.dart';
import 'package:first_app_flutter/game/theme/game_resolution.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:first_app_flutter/game/game.dart';

class GunIcon extends SpriteComponent with HasGameRef<SurvivalGame>, CollisionCallbacks {
  GunIcon(Vector2 position)
      : super(
    position: position,
    size: Vector2.all(16 * GameResolution.pixelScale),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Arrow bundle pickup (pixel art, gives ammo).
    sprite = await PixelSprite.sprite(
      PixelArtData.arrowBundle,
      PixelArtData.bundlePalette,
    );

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
