import 'package:first_app_flutter/game/components/bullet.dart';
import 'package:first_app_flutter/game/components/player.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/theme/game_resolution.dart';
import 'package:first_app_flutter/game/utils/AudioManager.dart';
import 'package:first_app_flutter/game/utils/zombie_sprite_preloader.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../animations/blood.dart';

class Zombie extends SpriteAnimationComponent
    with HasGameRef<SurvivalGame>, CollisionCallbacks {

  bool isReallyDead = false;
  bool isfocus = false;
  String name;
  ZombieSpritePreloader mySpriteLoaded;

  Zombie(String myName, Vector2 originalPosition, ZombieSpritePreloader mySpriteLoadedOriginal)
      : name = myName,
        isfocus = true,
        mySpriteLoaded = mySpriteLoadedOriginal,
        super(
          position: originalPosition
        );

  static const _speed = 50.0;
  Vector2 _direction = Vector2(0, 0);

  @override
  Future<void> onLoad() async {

    try {

      AudioManager().playZombieSound();
      animation = mySpriteLoaded.getAnimationForLine(0);

      size = Vector2.all(16 * GameResolution.pixelScale);
    } catch (e) {
      print("Erreur lors du chargement de l'animation : $e");
    }

    add(
      RectangleHitbox.relative(
        Vector2(0.6, 0.6),
        parentSize: size,
      ),
    );
  }

  Future<void> goDown() async {
    animation = mySpriteLoaded.getAnimationForLine(0);
  }

  Future<void> goLeft() async {
    animation = mySpriteLoaded.getAnimationForLine(1);
  }

  Future<void> goRight() async {
    animation = mySpriteLoaded.getAnimationForLine(2);
  }

  Future<void> goUp() async {
    animation = mySpriteLoaded.getAnimationForLine(3);
  }



  @override
  void update(double dt) {
    if(gameRef.endOfGame){
      return;
    }
    super.update(dt * 0.5);

    if(isfocus){
      _direction = computeDirection(position, (gameRef.playerPosition + Vector2(-60, -60)));
      var diff = _direction * _speed * dt;
      position.x += diff.x;
      position.y += diff.y;
    }
  }

  Vector2 computeDirection(Vector2 position, Vector2 playerPosition) {
    return convertToDirection(position - playerPosition);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    print('Collision détectée avec $other');

    if(other is Bullet){
      super.removeFromParent();

      AudioManager().playExplosedSound();

      isReallyDead = true;
      gameRef.score++;
      gameRef.updateText();
      gameRef.evalNextWave(mySpriteLoaded);
      return;
    }

    if(other is Player){
      isfocus = false;
      other.isDead = true;
      gameRef.finishGame(other.position);
    }
  }

  void showBlood(Vector2 lastPosition) {
    Blood endBloood = Blood(lastPosition);
    endBloood.onLoad();
    gameRef.add(endBloood);
  }

  Vector2 convertToDirection(Vector2 diff) {
    if (diff.x.abs() > diff.y.abs() ){
      if(diff.x > 0){
        goLeft();
        return Vector2(-1, 0);
      }else{
        goRight();
        return Vector2(1, 0);
      }
    }else{
      if(diff.y > 0){
        goUp();
        return Vector2(0, -1);
      }else{
        goDown();
        return Vector2(0, 1);
      }
    }
  }

}
