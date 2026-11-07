import 'dart:ui';

import 'package:flame/components.dart';

class RightPanel extends PositionComponent with HasGameRef {
  final String label;
  final Sprite iconSprite;
  final double iconSize = 64;
  final double borderWidth = 4;

  RightPanel({
    required this.label,
    required this.iconSprite,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Dimensions du panneau
    size = Vector2(100, gameRef.size.y); // largeur / hauteur du panneau
    anchor = Anchor.topRight;
    position = Vector2(gameRef.size.x, 0); // collé à droite

    // ---- Fond gris du panel ----
    add(
      RectangleComponent(
        size: size,
        anchor: Anchor.topLeft,
        paint: Paint()..color = const Color(0xFFCCCCCC), // gris clair
      ),
    );

    // ---- Texte au-dessus ----
    final text = TextComponent(
      text: label,
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 0),
    );

    // Fond noir = bord
    final border = RectangleComponent(
      size: Vector2(iconSize + borderWidth * 2, iconSize + borderWidth * 2),
      paint: Paint()..color = const Color(0xFF000000),
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y),
    );

    // Icône
    final icon = SpriteComponent(
      sprite: iconSprite,
      size: Vector2(iconSize, iconSize),
      anchor: Anchor.center,
      position: border.size / 2, // centrer dans le fond
    );

// On met l’icône dans le fond
    border.add(icon);

// On ajoute le tout au panneau
    add(border);
    add(text);
  }
}
