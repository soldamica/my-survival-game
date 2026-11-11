import 'dart:async';
import 'package:first_app_flutter/game/components/pixel/pixel_art_data.dart';
import 'package:first_app_flutter/game/components/pixel/pixel_sprite.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/theme/game_resolution.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
/// Ground made of 16x16 pixel-art grass tiles, integer upscaled.
class Background extends PositionComponent with HasGameRef<SurvivalGame> {
  Background() : super(priority: -10);
  late final Sprite _grass;
  @override
  FutureOr<void> onLoad() async {
    _grass = await PixelSprite.sprite(
      PixelArtData.grassTile,
      PixelArtData.grassPalette,
    );
  }
  @override
  void render(Canvas canvas) {
    const t = GameResolution.tile * GameResolution.pixelScale;
    final tileSize = Vector2.all(t);
    final pos = Vector2.zero();
    for (var y = 0.0; y < gameRef.size.y; y += t) {
      for (var x = 0.0; x < gameRef.size.x; x += t) {
        pos.setValues(x, y);
        _grass.render(canvas, position: pos, size: tileSize);
      }
    }
  }
}
