import 'package:first_app_flutter/game/components/components.dart';
import 'package:first_app_flutter/game/components/pixel/pixel_art_data.dart';
import 'package:first_app_flutter/game/components/pixel/pixel_sprite.dart';
import 'package:first_app_flutter/game/theme/game_resolution.dart';
import 'package:first_app_flutter/game/utils/AudioManager.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:first_app_flutter/game/game.dart';

class Bullet extends SpriteComponent with HasGameRef<SurvivalGame>, CollisionCallbacks {
  static Sprite? _arrowSprite;
  Vector2 _bulletDirection;
  Vector2 positionInitial;

  Bullet(Vector2 positionOrigin, Vector2 directionOrigin, double angleOrigin)
      :
        _bulletDirection = Vector2.copy(directionOrigin),
        positionInitial = Vector2.copy(positionOrigin),
        super(
        angle: angleOrigin,
        position: Vector2.copy(positionOrigin),
        size: Vector2(3, 9) * GameResolution.pixelScale,
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Pixel-art arrow (pointing up; rotated by `angle`).
    _arrowSprite ??= await PixelSprite.sprite(
      PixelArtData.arrow,
      PixelArtData.arrowPalette,
    );
    sprite = _arrowSprite;

    AudioManager().playPanSound();

    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is! Player){
      super.removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Mise à jour de la position de l'objet en fonction de sa vélocité
    position += _bulletDirection * 10;

    if(position.distanceTo(positionInitial) > 1000){
      super.removeFromParent();
    }
  }

}
