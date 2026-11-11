import 'dart:math' as math;

import 'package:first_app_flutter/game/components/components.dart';
import 'package:first_app_flutter/game/components/weapons/weapon.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/utils/heroes_sprite_preloader.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef<SurvivalGame>, CollisionCallbacks {

  HeroesSpritePreloader heroesSpritePreloader;
  bool isDead = false;
  final Set<LogicalKeyboardKey> pressedKeys = {};
  Set<Weapon> weapons = {};
  Weapon? currentWeapon;

  Player(Vector2 myposition, HeroesSpritePreloader heroesSpritePreloaderOrigin)
      : heroesSpritePreloader = heroesSpritePreloaderOrigin,
        super(
          position: myposition,
          anchor: Anchor.center,
        );

  static const _speed = 100.0;
  final _direction = Vector2.zero();
  Vector2 lastDirection = Vector2.zero();
  double bulletAngle = 0;

  /// Joystick tactile (mobile uniquement), null sur desktop.
  JoystickComponent? joystick;
  static const _joystickDeadZone = 0.15;
  bool _joystickActive = false;
  // 0 = bas, 1 = gauche, 2 = droite, 3 = haut, -1 = aucun
  int _joystickAnimLine = -1;

  @override
  Future<void> onLoad() async {

    initPosition();

    size = Vector2.all(40);

    add(
      RectangleHitbox.relative(
        Vector2(1, 1),
        parentSize: size,
      ),
    );

    add(
      KeyboardListenerComponent(
        keyUp: {
          LogicalKeyboardKey.arrowLeft: (_) {
            pressedKeys.remove(LogicalKeyboardKey.arrowLeft);
            _direction.x = 0;
            return false;
          },
          LogicalKeyboardKey.arrowRight: (_) {
            pressedKeys.remove(LogicalKeyboardKey.arrowRight);
            _direction.x = 0;
            return false;
          },
          LogicalKeyboardKey.arrowUp: (_) {
            pressedKeys.remove(LogicalKeyboardKey.arrowUp);
            _direction.y = 0;
            return false;
          },
          LogicalKeyboardKey.arrowDown: (_) {
            pressedKeys.remove(LogicalKeyboardKey.arrowDown);
            _direction.y = 0;
            return false;
          },
          LogicalKeyboardKey.space: (_) {
            shoot();
            return false;
          }
        },
        keyDown: {
          LogicalKeyboardKey.arrowLeft: (_) {
            if (pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) return false;
            pressedKeys.add(LogicalKeyboardKey.arrowLeft);
            _direction.x = -1;
            lastDirection = Vector2(-1, 0);
            bulletAngle = 3 * math.pi / 2;
            goLeft();
            return false;
          },
          LogicalKeyboardKey.arrowRight: (_) {
            if (pressedKeys.contains(LogicalKeyboardKey.arrowRight)) return false;
            pressedKeys.add(LogicalKeyboardKey.arrowRight);
            _direction.x = 1;
            lastDirection = Vector2(1, 0);
            bulletAngle = math.pi / 2;
            goRight();
            return false;
          },
          LogicalKeyboardKey.arrowUp: (_) {
            if (pressedKeys.contains(LogicalKeyboardKey.arrowUp)) return false;
            pressedKeys.add(LogicalKeyboardKey.arrowUp);
            _direction.y = -1;
            lastDirection = Vector2(0, -1);
            bulletAngle = 0;
            goUp();
            return false;
          },
          LogicalKeyboardKey.arrowDown: (_) {
            if (pressedKeys.contains(LogicalKeyboardKey.arrowDown)) return false;
            pressedKeys.add(LogicalKeyboardKey.arrowDown);
            _direction.y = 1;
            lastDirection = Vector2(0, 1);
            bulletAngle = math.pi;
            goDown();
            return false;
          },
        },
      ),
    );
  }

  void initPosition() async{
    bool success = false;
    int attempt = 0;
    int maxRetries = 3;
    while (attempt < maxRetries && !success) {
      animation = heroesSpritePreloader.getAnimationForLine(0);
      if(animation != null){
        success = true;
      }else{
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  void goDown() {
    if(!isDead){
      animation = heroesSpritePreloader.getAnimationForLine(0);
    }
  }

  void goLeft() {
    if(!isDead) {
      animation = heroesSpritePreloader.getAnimationForLine(1);
    }
  }

  void goRight() {
    if(!isDead) {
      animation = heroesSpritePreloader.getAnimationForLine(2);
    }
  }

  void goUp() {
    if(!isDead) {
      animation = heroesSpritePreloader.getAnimationForLine(3);
    }
  }


  @override
  void update(double dt) {
    super.update(dt * 0.5);

    _applyJoystick();

    // Limites proportionnelles à l'écran (ex-valeurs 500..1500 / 250..750 sur 2000x1000).
    final upLimitX = gameRef.size.x * 0.75;
    final downLimitX = gameRef.size.x * 0.25;
    final upLimitY = gameRef.size.y * 0.75;
    final downLimitY = gameRef.size.y * 0.25;

    var diff = _direction * _speed * dt;
    var tmp = position + diff;

    if(tmp.x > upLimitX) {
      position.x = upLimitX;
    } else if(tmp.x < downLimitX){
      position.x = downLimitX;
    } else {
      position.x += diff.x;
    }

    if(tmp.y > upLimitY){
      position.y = upLimitY;
    } else if(tmp.y < downLimitY){
      position.y = downLimitY;
    } else {
      position.y += diff.y;
    }

    gameRef.playerPosition = position;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    //print('Collision détectée avec $other');
    if(other is GunIcon){
      gameRef.bullets = 50;
      gameRef.updateText();
    } else if (other is Zombie){
      animation = null;
    }
  }

  void shoot() {
    if (gameRef.bullets <= 0) return;
    final dir = getBulletDirection(_direction, lastDirection);
    if (dir.isZero()) return;
    final normalized = dir.normalized();
    gameRef.add(
      Bullet(
        position + getBulletStart(normalized),
        normalized,
        normalized.screenAngle(),
      ),
    );
    gameRef.bullets--;
    gameRef.updateText();
  }

  void _applyJoystick() {
    final stick = joystick;
    if (stick == null) return;

    if (stick.intensity < _joystickDeadZone) {
      if (_joystickActive) {
        _joystickActive = false;
        _joystickAnimLine = -1;
        _direction.setZero();
      }
      return;
    }

    _joystickActive = true;
    final delta = stick.relativeDelta;
    _direction.setFrom(delta);
    lastDirection = delta.normalized();
    bulletAngle = lastDirection.screenAngle();

    final int line;
    if (delta.x.abs() > delta.y.abs()) {
      line = delta.x < 0 ? 1 : 2;
    } else {
      line = delta.y < 0 ? 3 : 0;
    }
    if (line != _joystickAnimLine) {
      _joystickAnimLine = line;
      switch (line) {
        case 0:
          goDown();
          break;
        case 1:
          goLeft();
          break;
        case 2:
          goRight();
          break;
        case 3:
          goUp();
          break;
      }
    }
  }

  Vector2 getBulletDirection(Vector2 direction, Vector2 lastDirection) {
    return direction == Vector2.zero() ? lastDirection : direction;
  }

  Vector2 getBulletStart(Vector2 direction) {
    return Vector2(direction.x * 30, direction.y * 20);
  }

}
