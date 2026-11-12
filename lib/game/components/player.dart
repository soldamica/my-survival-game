import 'package:first_app_flutter/game/components/components.dart';
import 'package:first_app_flutter/game/components/weapons/weapon.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/character_sheet.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:first_app_flutter/game/iso/iso_body.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// Hero. Arrow keys move in screen directions (up = up on screen),
/// space attacks with the equipped weapon, E switches weapon.
/// Logic runs on the ground plane.
class Player extends SpriteAnimationComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks, IsoBody {
  Player(Vector2 startGround, this.sheet, this.attackSheet)
      : super(
          size: Vector2.all(CharacterSheet.frame),
          anchor: CharacterSheet.feet,
        ) {
    ground.setFrom(startGround);
  }

  final CharacterSheet sheet;
  final CharacterSheet attackSheet;
  bool isDead = false;

  /// Points de vie.
  double maxHp = 100;
  double hp = 100;

  /// Dégâts infligés par le héros.
  double attackPower = 50;

  /// Reçoit des dégâts ; meurt à 0 PV.
  void takeDamage(double amount) {
    if (isDead) return;
    hp = (hp - amount).clamp(0, maxHp).toDouble();
    if (hp <= 0) {
      isDead = true;
      game.finishGame(position);
    }
  }

  /// Screen pixels per second.
  static const _speed = 160.0;

  /// Sword reach in screen pixels when striking left/right...
  static const _swordReach = 80.0;

  /// ...and when striking up/down (longer, as requested).
  static const _swordReachVertical = 110.0;

  /// Remaining time of the current swing (0 = not attacking).
  double _attackTime = 0;
  bool _hitDone = false;

  /// Current input, screen space (x right, y down).
  final _direction = Vector2.zero();
  Vector2 lastDirection = Vector2(0, 1);
  final Set<LogicalKeyboardKey> _pressed = {};
  int _row = 0;
  late final Sprite _shadow;

  /// Touch joystick (mobile only), null on desktop.
  JoystickComponent? joystick;
  static const _joystickDeadZone = 0.15;

  static final _keys = [
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
  ];

  @override
  Future<void> onLoad() async {
    animation = sheet.row(_row);
    playing = false;
    _shadow = Sprite(game.images.fromCache('iso/shadow.png'));
    // Lower body only, so overlaps look right in isometric view.
    add(RectangleHitbox(position: Vector2(34, 40), size: Vector2(28, 48)));
    add(KeyboardListenerComponent(
      keyDown: {
        for (final k in _keys) k: (_) => _onKey(k, true),
      },
      keyUp: {
        for (final k in _keys) k: (_) => _onKey(k, false),
        LogicalKeyboardKey.space: (_) {
          if (game.canProcessInput()) attack();
          return false;
        },
        LogicalKeyboardKey.keyE: (_) {
          game.toggleWeapon();
          return false;
        },
      },
    ));
    syncIso();
  }

  @override
  void render(Canvas canvas) {
    renderShadow(canvas, _shadow);
    super.render(canvas);
  }

  bool _onKey(LogicalKeyboardKey key, bool down) {
    down ? _pressed.add(key) : _pressed.remove(key);
    double axis(LogicalKeyboardKey k) => _pressed.contains(k) ? 1.0 : 0.0;
    _direction
      ..x = axis(LogicalKeyboardKey.arrowRight) - axis(LogicalKeyboardKey.arrowLeft)
      ..y = axis(LogicalKeyboardKey.arrowDown) - axis(LogicalKeyboardKey.arrowUp);
    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    final stick = joystick;
    if (stick != null) {
      if (stick.intensity >= _joystickDeadZone) {
        _direction.setFrom(stick.relativeDelta);
      } else if (_pressed.isEmpty) {
        _direction.setZero();
      }
    }

    if (_attackTime > 0) {
      _attackTime -= dt;
      if (!_hitDone && _attackTime <= attackSheet.duration / 2) {
        _hitDone = true;
        _applySwordHit();
      }
      if (_attackTime > 0) {
        syncIso();
        return; // rooted while swinging
      }
      animation = sheet.row(_row);
    }

    final moving = !_direction.isZero();
    playing = moving;
    if (moving) {
      final screenDir = _direction.normalized();
      lastDirection = screenDir;
      ground.setFrom(Iso.clampToArena(
          ground + Iso.deltaToGround(screenDir * _speed * dt)));
      final row = Iso.dirRow(screenDir, _row);
      if (row != _row) {
        _row = row;
        animation = sheet.row(row);
      }
    }
    syncIso();
    game.playerGround.setFrom(ground);
    game.playerPosition.setFrom(position);
  }

  /// Main action: sword swing or bow shot, depending on the equipped weapon.
  void attack() {
    if (isDead || _attackTime > 0) return;
    switch (game.weapon) {
      case Weapon.sword:
        _startSwing();
      case Weapon.bow:
        shoot(); // does nothing without arrows
    }
  }

  void shoot() {
    if (game.bullets <= 0) return;
    final groundDir = _facingGround();
    game.world.add(Bullet(ground + groundDir * 20, groundDir));
    game.bullets--;
  }

  Vector2 _facingGround() {
    final screenDir =
        _direction.isZero() ? lastDirection : _direction.normalized();
    return Iso.deltaToGround(screenDir).normalized();
  }

  void _startSwing() {
    if (!_direction.isZero()) {
      lastDirection = _direction.normalized();
      _row = Iso.dirRow(lastDirection, _row);
    }
    _attackTime = attackSheet.duration;
    _hitDone = false;
    animation = attackSheet.row(_row);
    animationTicker?.reset();
    playing = true;
  }

  /// Kills zombies in a cone in front of the hero.
  /// Measured on screen (not on the ground plane), so the reach looks the
  /// same in every direction; up/down strikes get a longer reach.
  void _applySwordHit() {
    final facing = Iso.deltaToScreen(_facingGround()).normalized();
    final vertical = facing.y.abs(); // 0 = left/right, 1 = up/down
    final reach = _swordReach + (_swordReachVertical - _swordReach) * vertical;
    for (final z in game.world.children.whereType<Mob>().toList()) {
      if (z.isReallyDead) continue;
      final to = Iso.deltaToScreen(z.ground - ground);
      final dist = to.length;
      if (dist > reach) continue;
      if (dist < 16 || facing.dot(to / dist) > 0.3) {
        z.takeDamage(attackPower);
      }
    }
  }
}
