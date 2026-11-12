import 'dart:math' as math;

import 'package:flame/components.dart';

/// Isometric projection (2:1). Game logic lives on a flat "ground" plane;
/// only rendering is projected. One ground unit = 1 screen px horizontally.
class Iso {
  Iso._();

  /// Fixed logical resolution (upscaled by the camera).
  static const double viewWidth = 1152;
  static const double viewHeight = 648;

  /// Ground size of one floor tile (drawn as a 64x32 diamond).
  static const double tile = 32;

  /// Arena half-size in ground units (arena = [-arena, arena]²).
  static const double arena = 480;

  /// Ground -> screen (world) position.
  static Vector2 toScreen(Vector2 g) => Vector2(g.x - g.y, (g.x + g.y) / 2);

  /// Ground delta -> screen delta (same linear map).
  static Vector2 deltaToScreen(Vector2 g) => toScreen(g);

  /// Screen delta -> ground delta (inverse map).
  static Vector2 deltaToGround(Vector2 s) =>
      Vector2(s.x / 2 + s.y, s.y - s.x / 2);

  /// Draw order: things closer to the viewer (bigger x+y) are drawn last.
  static int depth(Vector2 g) => (g.x + g.y).round();

  static Vector2 clampToArena(Vector2 g, [double margin = 16]) => Vector2(
        g.x.clamp(-arena + margin, arena - margin),
        g.y.clamp(-arena + margin, arena - margin),
      );

  /// Sprite-sheet row for a screen-space direction.
  /// Rows: 0 S, 1 SW, 2 W, 3 NW, 4 N, 5 NE, 6 E, 7 SE.
  static int dirRow(Vector2 screenDir, int fallback) {
    if (screenDir.isZero()) return fallback;
    final k = (math.atan2(screenDir.y, screenDir.x) / (math.pi / 4)).round();
    return ((k % 8) + 8 + 6) % 8;
  }
}
