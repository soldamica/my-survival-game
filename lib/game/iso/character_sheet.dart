import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Loads an 8-direction walk sheet (rows S, SW, W, NW, N, NE, E, SE;
/// 8 frames of 48x48 per row). Replace the PNG to change the art.
class CharacterSheet {
  static const double frame = 48;
  static const int directions = 8;
  static const int frames = 8;

  final List<SpriteAnimation> _rows = [];

  Future<void> load(Game game, String path, {double stepTime = 0.1}) async {
    final image = await game.images.load(path);
    for (var row = 0; row < directions; row++) {
      _rows.add(SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: frames,
          amountPerRow: frames,
          stepTime: stepTime,
          textureSize: Vector2.all(frame),
          texturePosition: Vector2(0, row * frame),
        ),
      ));
    }
  }

  SpriteAnimation row(int i) => _rows[i.clamp(0, _rows.length - 1)];
}
