import 'package:first_app_flutter/game/components/components.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/character_sheet.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:first_app_flutter/game/iso/iso_body.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// Hero. Arrow keys move in screen directions (up = up on screen),
/// space shoots an arrow. Logic runs on the ground plane.
class Player extends SpriteAnimationComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks, IsoBody {
  Player(Vector2 startGround, this.sheet)
      : super(
          size: Vector2.all(CharacterSheet.frame),
          anchor: const Anchor(0.5, 44 / 48), // feet
        ) {
    ground.setFrom(startGround);
  }

  final CharacterSheet sheet;
  bool isDead = false;

  /// Screen pixels per second.
  static const _speed = 80.0;

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
    add(RectangleHitbox(position: Vector2(16, 18), size: Vector2(16, 26)));
    add(KeyboardListenerComponent(
      keyDown: {
        for (final k in _keys) k: (_) => _onKey(k, true),
      },
      keyUp: {
        for (final k in _keys) k: (_) => _onKey(k, false),
        LogicalKeyboardKey.space: (_) {
          if (game.canProcessInput()) shoot();
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

  void shoot() {
    if (game.bullets <= 0) return;
    final screenDir =
        _direction.isZero() ? lastDirection : _direction.normalized();
    final groundDir = Iso.deltaToGround(screenDir).normalized();
    game.world.add(Bullet(ground + groundDir * 10, groundDir));
    game.bullets--;
  }
}
