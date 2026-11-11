import 'dart:ui';

import 'package:flame/components.dart';

/// Convertit des grilles de caractères + palette en images pixel art.
/// `.` ou espace = transparent.
class PixelSprite {
  PixelSprite._();

  static Future<Image> image(List<String> grid, Map<String, Color> palette) {
    final h = grid.length;
    final w = grid.fold<int>(0, (m, r) => r.length > m ? r.length : m);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;
    for (var y = 0; y < h; y++) {
      final row = grid[y];
      for (var x = 0; x < row.length; x++) {
        final color = palette[row[x]];
        if (color == null) continue;
        paint.color = color;
        canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1), paint);
      }
    }
    return recorder.endRecording().toImage(w, h);
  }

  static Future<Sprite> sprite(List<String> grid, Map<String, Color> palette) async =>
      Sprite(await image(grid, palette));

  /// Construit une spritesheet : `rows[ligne][frame]` = grille.
  /// Toutes les frames doivent avoir la même taille.
  static Future<Image> sheet(
    List<List<List<String>>> rows,
    Map<String, Color> palette,
  ) async {
    final fh = rows.first.first.length;
    final fw = rows.first.first.first.length;
    final cols = rows.fold<int>(0, (m, r) => r.length > m ? r.length : m);
    final merged = <String>[];
    for (final row in rows) {
      for (var y = 0; y < fh; y++) {
        final buf = StringBuffer();
        for (var c = 0; c < cols; c++) {
          buf.write(c < row.length ? row[c][y].padRight(fw, '.') : '.' * fw);
        }
        merged.add(buf.toString());
      }
    }
    return image(merged, palette);
  }

  /// Miroir horizontal d'une grille (utile pour gauche/droite).
  static List<String> mirror(List<String> grid) =>
      grid.map((r) => r.split('').reversed.join()).toList();
}
