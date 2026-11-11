import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'snes_palette.dart';
/// Typographie pixel partagée (Press Start 2P).
class PixelText {
  PixelText._();
  static TextStyle style({double size = 8, Color color = SnesPalette.text}) =>
      GoogleFonts.pressStart2p(
        fontSize: size,
        color: color,
        shadows: const [
          Shadow(color: SnesPalette.outline, offset: Offset(1, 1)),
        ],
      );
  static TextPaint paint({double size = 8, Color color = SnesPalette.text}) =>
      TextPaint(style: style(size: size, color: color));
}
