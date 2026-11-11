import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Isometric floor: 32x16 diamond tiles ('iso/floor_0..3.png') over the whole
/// arena, baked once into a single image.
class Background extends PositionComponent with HasGameReference<SurvivalGame> {
  Background() : super(priority: -(1 << 20));

  static const _variants = 4;
  late final ui.Image _baked;
  final _paint = Paint()..filterQuality = FilterQuality.none;

  @override
  Future<void> onLoad() async {
    final tiles = [
      for (var i = 0; i < _variants; i++) game.images.fromCache('iso/floor_$i.png'),
    ];
    const a = Iso.arena;
    const n = (2 * a) ~/ Iso.tile;
    // Screen bounds of the arena diamond.
    position = Vector2(-2 * a, -a);
    size = Vector2(4 * a, 2 * a + Iso.tile);

    final rng = math.Random(7);
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        final g = Vector2(-a + i * Iso.tile, -a + j * Iso.tile);
        final s = Iso.toScreen(g) - position;
        final img = tiles[rng.nextInt(10) < 7 ? 0 : 1 + rng.nextInt(_variants - 1)];
        canvas.drawImage(img, Offset(s.x - Iso.tile, s.y), _paint);
      }
    }
    _baked = await rec.endRecording().toImage(size.x.toInt(), size.y.toInt());
  }

  @override
  void render(Canvas canvas) => canvas.drawImage(_baked, Offset.zero, _paint);
}

/// Darkness around the hero (screen space, drawn under the HUD).
class LightRadius extends PositionComponent with HasGameReference<SurvivalGame> {
  LightRadius() : super(priority: 10);

  final _paint = Paint();

  @override
  void render(Canvas canvas) {
    final center = game.heroScreenAnchor;
    _paint.shader = const RadialGradient(
      colors: [Color(0x00000000), Color(0x00000000), Color(0xE6000000)],
      stops: [0, 0.35, 1],
    ).createShader(Rect.fromCircle(center: Offset(center.x, center.y), radius: 420));
    canvas.drawRect(const Rect.fromLTWH(0, 0, Iso.viewWidth, Iso.viewHeight), _paint);
  }
}
