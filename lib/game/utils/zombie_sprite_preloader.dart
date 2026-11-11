import 'package:first_app_flutter/game/components/pixel/pixel_art_data.dart';
import 'package:first_app_flutter/game/components/pixel/pixel_sprite.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class ZombieSpritePreloader {

  final List<SpriteAnimation> _animations = [];

  final Game game;

  ZombieSpritePreloader({required this.game});
  
  /// Builds walk animations from code-generated pixel art (hero grids,
  /// zombie palette). Lines: 0 = down, 1 = left, 2 = right, 3 = up.
  Future<void> preloadAnimations(int totalLines) async {
    final sheet = await PixelSprite.sheet(
      PixelArtData.characterRows,
      PixelArtData.zombiePalette,
    );
    for (int line = 0; line < totalLines; line++) {
      _animations.add(
        SpriteAnimation.fromFrameData(
          sheet,
          SpriteAnimationData.sequenced(
            amount: 4,
            stepTime: 0.3,
            textureSize: Vector2.all(16),
            amountPerRow: 4,
            texturePosition: Vector2(0, line * 16.0),
            loop: false,
          ),
        ),
      );
    }
  }

  SpriteAnimation? getAnimationForLine(int line) {
    if (line < 0 || line >= _animations.length) {
      print("error when load sprite with line : $line");
      return null; // Retourne null si la ligne demandée est invalide
    }
    return _animations[line];
  }
}
