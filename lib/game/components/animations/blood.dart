import 'package:first_app_flutter/game/game.dart';
import 'package:flame/components.dart';

class Blood extends SpriteComponent with HasGameRef<SurvivalGame>{
  static const _spriteBlood = 'blood.png';

  Blood(Vector2 position)
      : super(
    position: position + Vector2(-150.0, -150.0),
    size: Vector2(300, 300),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Charger le sprite et l'assigner à ce composant
    sprite = await Sprite.load(_spriteBlood);
  }
}