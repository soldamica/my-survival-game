import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Barre de vie dessinée au-dessus d'un monstre, avec son nom écrit dedans.
/// Coordonnées locales au cadre 96x96 du sprite.
class MobHealthBar {
  MobHealthBar(this.name);

  final String name;

  static const double width = 64;
  static const double height = 11;
  static final Vector2 _pos = Vector2(16, -6);

  static final Paint _border = Paint()..color = const Color(0xFF101010);
  static final Paint _back = Paint()..color = const Color(0xFF4A0A0A);
  static final Paint _fill = Paint()..color = const Color(0xFFC81E1E);
  static final Paint _shine = Paint()..color = const Color(0x55FFFFFF);

  static final TextPaint _text = TextPaint(
    style: const TextStyle(
      fontSize: 8,
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Color(0xFF000000), offset: Offset(1, 1))],
    ),
  );

  void render(Canvas canvas, double hp, double maxHp) {
    final ratio = maxHp <= 0 ? 0.0 : (hp / maxHp).clamp(0.0, 1.0);
    final x = _pos.x, y = _pos.y;
    canvas.drawRect(Rect.fromLTWH(x, y, width, height), _border);
    canvas.drawRect(Rect.fromLTWH(x + 1, y + 1, width - 2, height - 2), _back);
    final w = (width - 2) * ratio;
    if (w > 0) {
      canvas.drawRect(Rect.fromLTWH(x + 1, y + 1, w, height - 2), _fill);
      canvas.drawRect(Rect.fromLTWH(x + 1, y + 1, w, 2), _shine);
    }
    _text.render(
      canvas,
      name,
      Vector2(x + width / 2, y + height / 2),
      anchor: Anchor.center,
    );
  }
}
