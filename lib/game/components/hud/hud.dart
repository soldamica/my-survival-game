import 'package:first_app_flutter/game/components/weapons/weapon.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/gothic.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Diablo-like bottom panel. Art is 640x72, drawn at x[scale] to fit the
/// 960-wide view: life orb (left),
/// arrows orb (right), skills (equipped one highlighted), kills and wave.
class Hud extends PositionComponent with HasGameReference<SurvivalGame> {
  Hud()
      : super(
          position: Vector2(0, Iso.viewHeight - panelHeight),
          size: Vector2(Iso.viewWidth / _scale, panelHeight / _scale),
          scale: Vector2.all(_scale),
          priority: 100,
        );

  static const double _scale = Iso.viewWidth / 640;
  static const double panelHeight = 72 * _scale;
  static const double _orb = 64;
  static const int maxArrows = 50;

  late final Sprite _panel, _frame, _red, _blue, _bow, _sword;
  final TextPaint _label = TextPaint(style: Gothic.font(size: 9, color: Gothic.gold));
  final TextPaint _value = TextPaint(style: Gothic.font(size: 12));
  final _lock = Paint()..color = const Color(0xB0000000);
  final _active = Paint()
    ..color = Gothic.gold
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  Future<void> onLoad() async {
    Sprite s(String n) => Sprite(game.images.fromCache('iso/$n.png'));
    _panel = s('hud_panel');
    _frame = s('orb_frame');
    _red = s('orb_red');
    _blue = s('orb_blue');
    _bow = s('skill_bow');
    _sword = s('skill_sword');
  }

  @override
  void render(Canvas canvas) {
    _panel.render(canvas);

    final life = game.endOfGame ? 0.0 : 1.0;
    final arrows = (game.bullets / maxArrows).clamp(0.0, 1.0);
    _orbAt(canvas, Vector2(4, 6), _red, life);
    _orbAt(canvas, Vector2(size.x - _orb - 4, 6), _blue, arrows);
    _value.render(canvas, '${game.bullets}', Vector2(size.x - 36, 38),
        anchor: Anchor.center);

    // Skills: sword (always usable) and bow (dimmed without arrows).
    const y = 32.0;
    const swordRect = Rect.fromLTWH(258, y, 28, 28);
    const bowRect = Rect.fromLTWH(354, y, 28, 28);
    _sword.render(canvas, position: Vector2(swordRect.left, y));
    _label.render(canvas, 'ÉPÉE', Vector2(272, y - 2), anchor: Anchor.bottomCenter);
    _bow.render(canvas, position: Vector2(bowRect.left, y));
    if (game.bullets <= 0) canvas.drawRect(bowRect, _lock);
    _label.render(canvas, 'ARC', Vector2(368, y - 2), anchor: Anchor.bottomCenter);
    canvas.drawRect(
      (game.weapon == Weapon.sword ? swordRect : bowRect).inflate(2),
      _active,
    );

    // Kills / wave.
    _label.render(canvas, 'TUÉS', Vector2(320, y), anchor: Anchor.topCenter);
    _value.render(canvas, '${game.score}', Vector2(320, y + 12), anchor: Anchor.topCenter);
    _label.render(canvas, 'VAGUE ${game.wave}', Vector2(320, 6), anchor: Anchor.topCenter);
  }

  /// Draws an orb filled from the bottom by [ratio] (0..1).
  void _orbAt(Canvas canvas, Vector2 pos, Sprite fill, double ratio) {
    if (ratio > 0) {
      final top = pos.y + _orb * (1 - ratio);
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(pos.x, top, _orb, pos.y + _orb - top));
      fill.render(canvas, position: pos);
      canvas.restore();
    }
    _frame.render(canvas, position: pos);
  }
}
