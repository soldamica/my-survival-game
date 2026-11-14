import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Filtre rouge furtif appliqué au sprite quand le personnage perd des PV.
/// Appeler [flashHit] dans `takeDamage`.
mixin HitFlash on SpriteAnimationComponent {
  /// Durée du flash en secondes.
  static const double flashDuration = 0.15;

  static const ColorFilter _redFilter =
      ColorFilter.mode(Color(0xB0FF2020), BlendMode.srcATop);

  double _flashTimer = 0;

  /// Déclenche (ou relance) le flash rouge.
  void flashHit() {
    _flashTimer = flashDuration;
    paint.colorFilter = _redFilter;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) paint.colorFilter = null;
    }
  }
}
