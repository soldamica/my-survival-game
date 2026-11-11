import 'package:first_app_flutter/game/components/weapons/weapon.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/gothic.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

/// Top-right button: shows the equipped weapon, tap/click to switch.
class WeaponSwitchButton extends PositionComponent
    with HasGameReference<SurvivalGame>, TapCallbacks {
  WeaponSwitchButton()
      : super(
          position: Vector2(Iso.viewWidth - 12, 12),
          size: Vector2.all(_size),
          anchor: Anchor.topRight,
          priority: 150,
        );

  static const double _size = 56;

  final Map<Weapon, Sprite> _icons = {};
  final _bg = Paint()..color = Gothic.stone;
  final _frame = Paint()
    ..color = Gothic.gold
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final _dim = Paint()..color = const Color(0xA0000000);
  final _label = TextPaint(style: Gothic.font(size: 11, color: Gothic.gold));
  final _hint = TextPaint(style: Gothic.font(size: 8));
  bool _pressed = false;

  @override
  Future<void> onLoad() async {
    for (final w in Weapon.values) {
      _icons[w] = Sprite(game.images.fromCache(w.icon));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _pressed = true;
    game.toggleWeapon();
  }

  @override
  void onTapUp(TapUpEvent event) => _pressed = false;

  @override
  void onTapCancel(TapCancelEvent event) => _pressed = false;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect, _bg);
    final weapon = game.weapon;
    _icons[weapon]!.render(canvas, position: Vector2.all(4), size: size - Vector2.all(8));
    // Bow without arrows: shown dimmed (unusable).
    if (weapon == Weapon.bow && game.bullets <= 0) canvas.drawRect(rect, _dim);
    _frame.color = _pressed ? Gothic.text : Gothic.gold;
    canvas.drawRect(rect.deflate(1), _frame);
    _label.render(canvas, weapon.label, Vector2(size.x / 2, size.y + 4),
        anchor: Anchor.topCenter);
    _hint.render(canvas, '[E] changer', Vector2(size.x / 2, size.y + 20),
        anchor: Anchor.topCenter);
  }
}
