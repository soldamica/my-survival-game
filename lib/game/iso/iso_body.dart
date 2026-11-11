import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Shadow (48x24) under a 96x96 character frame whose feet are at (48, 88).
/// Call from render() before super.render(). Image: 'iso/shadow.png'.
final _shadowPos = Vector2(24, 76);
void renderShadow(Canvas canvas, Sprite shadow) =>
    shadow.render(canvas, position: _shadowPos);

/// Component placed on the ground plane: keeps [ground] as logical position,
/// projects it to [position] and sorts by depth each frame.
mixin IsoBody on PositionComponent {
  final Vector2 ground = Vector2.zero();

  /// Extra screen offset (e.g. arrow flying at chest height).
  double elevation = 0;

  void syncIso() {
    position
      ..setFrom(Iso.toScreen(ground))
      ..y -= elevation;
    final d = Iso.depth(ground);
    if (priority != d) priority = d;
  }
}
