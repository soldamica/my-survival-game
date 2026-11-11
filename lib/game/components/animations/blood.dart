import 'package:first_app_flutter/game/game.dart';
import 'package:flame/components.dart';

/// Blood splash at the hero's death position (screen/world coordinates).
class Blood extends SpriteComponent with HasGameReference<SurvivalGame> {
  Blood(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(128),
          anchor: Anchor.center,
          priority: 1 << 20,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('blood.png');
  }
}
