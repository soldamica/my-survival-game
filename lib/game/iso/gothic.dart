import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark gothic palette (Diablo-like).
class Gothic {
  Gothic._();

  static const gold = Color(0xFFC8A860);
  static const goldDark = Color(0xFF7A6436);
  static const blood = Color(0xFFB02018);
  static const stone = Color(0xFF26221E);
  static const stoneLight = Color(0xFF5A5046);
  static const text = Color(0xFFD8D0C0);
  static const night = Color(0xFF000000);

  static TextStyle font({double size = 10, Color color = text}) =>
      GoogleFonts.cinzel(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.w700,
        shadows: const [Shadow(color: night, offset: Offset(1, 1))],
      );
}
