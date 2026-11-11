import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Loads an 8-direction walk sheet (rows S, SW, W, NW, N, NE, E, SE;
/// 8 frames of 96x96 per row, feet at (48, 88)). Replace the PNG to change the art.
class CharacterSheet {
  static const double frame = 96;

  /// Feet position inside a frame (anchor of characters).
  static const Anchor feet = Anchor(0.5, 88 / 96);
  static const int directions = 8;

  CharacterSheet({this.frames = 8, this.loop = true});

  /// Frames per row (8 for walk, 4 for the attack sheet).
  final int frames;
  final bool loop;
  double stepTime = 0.1;

  final List<SpriteAnimation> _rows = [];

  /// Total duration of one row.
  double get duration => frames * stepTime;

  Future<void> load(Game game, String path, {double stepTime = 0.1}) async {
    this.stepTime = stepTime;
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
          loop: loop,
        ),
      ));
    }
  }

  SpriteAnimation row(int i) => _rows[i.clamp(0, _rows.length - 1)];
}
