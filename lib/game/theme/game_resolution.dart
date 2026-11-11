import 'package:flame/components.dart';

/// Résolution logique fixe façon SNES (16:9), upscalée d'un facteur entier.
class GameResolution {
  GameResolution._();

  static const double width = 384;
  static const double height = 216;
  static const double tile = 16;

  /// Integer upscale applied to every pixel-art sprite (1 art pixel = 3 screen px).
  static const double pixelScale = 3;

  static Vector2 get size => Vector2(width, height);
}
