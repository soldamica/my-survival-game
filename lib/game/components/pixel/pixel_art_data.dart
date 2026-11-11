import 'dart:ui';

import 'package:first_app_flutter/game/components/pixel/pixel_sprite.dart';
import 'package:first_app_flutter/game/theme/snes_palette.dart';

/// Original 16-bit pixel art grids. '.' = transparent.
class PixelArtData {
  PixelArtData._();

  // ---------- Characters (16x16, 4 rows x 4 frames) ----------
  // Rows: 0 = down, 1 = left, 2 = right, 3 = up.

  static const _bodyDown = [
    '.....oooooo.....',
    '....oGGGGGGo....',
    '...oGGggggGGo...',
    '...ohhhhhhhho...',
    '..ohssssssssho..',
    '..ohsessssesho..',
    '...osssssssso...',
    '....oossssoo....',
    '..oogGggggGgoo..',
    '.osogGggggGgoso.',
    '.osoggbbbbggoso.',
    '..oogggyygggoo..',
  ];

  static const _bodyUp = [
    '.....oooooo.....',
    '....oGGGGGGo....',
    '...oGGggggGGo...',
    '...ohhhhhhhho...',
    '..ohhhhhhhhhho..',
    '..ohhhhhhhhhho..',
    '...ohhhhhhhho...',
    '....oohhhhoo....',
    '..oogGggggGgoo..',
    '.osogGggggGgoso.',
    '.osoggbbbbggoso.',
    '..ooggggggggoo..',
  ];

  static const _bodyRight = [
    '.....oooooo.....',
    '....oGGGGGGo....',
    '...oGGggggGGo...',
    '...ohhhhhhhho...',
    '...ohhhsssssso..',
    '...ohhssssseso..',
    '....ohsssssso...',
    '.....ossssoo....',
    '....oogGgggoo...',
    '...oggGgggsso...',
    '...ogbbbbbbgo...',
    '...oggggyggo....',
  ];

  static const _legsStand = [
    '...oggggggggo...',
    '....obbo.obbo...',
    '....obbo.obbo...',
    '....oooo.oooo...',
  ];
  static const _legsA = [
    '...oggggggggo...',
    '....obbo.obbo...',
    '....obbo..oo....',
    '....oooo........',
  ];
  static const _legsB = [
    '...oggggggggo...',
    '....obbo.obbo...',
    '.....oo..obbo...',
    '.........oooo...',
  ];

  static List<List<String>> _walk(List<String> body) => [
        [...body, ..._legsStand],
        [...body, ..._legsA],
        [...body, ..._legsStand],
        [...body, ..._legsB],
      ];

  static List<List<List<String>>> get characterRows => [
        _walk(_bodyDown),
        _walk(_bodyRight).map(PixelSprite.mirror).toList(),
        _walk(_bodyRight),
        _walk(_bodyUp),
      ];

  static const Map<String, Color> heroPalette = {
    'o': SnesPalette.outline,
    'G': SnesPalette.heroTunicLight,
    'g': SnesPalette.heroTunic,
    'h': SnesPalette.hair,
    's': SnesPalette.skin,
    'e': SnesPalette.outline,
    'b': SnesPalette.leather,
    'y': SnesPalette.gold,
  };

  static const Map<String, Color> zombiePalette = {
    'o': SnesPalette.outline,
    'G': SnesPalette.zombieClothLight,
    'g': SnesPalette.zombieCloth,
    'h': SnesPalette.zombieSkinDark,
    's': SnesPalette.zombieSkin,
    'e': SnesPalette.zombieEye,
    'b': SnesPalette.zombieSkinDark,
    'y': SnesPalette.leather,
  };

  // ---------- Arrow (3x9, pointing up) ----------
  static const arrow = [
    '.m.',
    'mmm',
    '.w.',
    '.w.',
    '.w.',
    '.w.',
    '.w.',
    'fwf',
    'f.f',
  ];
  static const Map<String, Color> arrowPalette = {
    'm': SnesPalette.metal,
    'w': SnesPalette.wood,
    'f': SnesPalette.feather,
  };

  // ---------- Pickup: bundle of arrows (16x16) ----------
  static const arrowBundle = [
    '................',
    '...m....m....m..',
    '..mmm..mmm..mmm.',
    '...w....w....w..',
    '...w....w....w..',
    '...w....w....w..',
    '..owooooowoooowo',
    '..obbbbbbbbbbbbo',
    '..oyyyyyyyyyyyyo',
    '..obbbbbbbbbbbbo',
    '..owooooowoooowo',
    '...w....w....w..',
    '..fwf..fwf..fwf.',
    '..f.f..f.f..f.f.',
    '................',
    '................',
  ];
  static const Map<String, Color> bundlePalette = {
    'o': SnesPalette.outline,
    'm': SnesPalette.metal,
    'w': SnesPalette.wood,
    'f': SnesPalette.feather,
    'b': SnesPalette.leather,
    'y': SnesPalette.gold,
  };

  // ---------- HUD icons ----------
  static const bow = [
    '.....oo.........',
    '....owwo........',
    '....ol.wo.......',
    '....ol..wo......',
    '....ol...wo.....',
    '....ol...wo.....',
    '....ol....wo....',
    '....ol....bo....',
    '....ol....bo....',
    '....ol....wo....',
    '....ol...wo.....',
    '....ol...wo.....',
    '....ol..wo......',
    '....ol.wo.......',
    '....owwo........',
    '.....oo.........',
  ];
  static const Map<String, Color> bowPalette = {
    'o': SnesPalette.outline,
    'w': SnesPalette.wood,
    'b': SnesPalette.leather,
    'l': SnesPalette.feather,
  };

  static const arrowIcon = [
    '......mo',
    '.....mm.',
    '....w...',
    '...w....',
    '..w.....',
    'fw......',
    'ff......',
    '........',
  ];

  static const zombieIcon = [
    '.oooooo.',
    'ohhhhhho',
    'ossssso.',
    'oseseso.',
    'osssssso',
    '.ossbso.',
    '..oooo..',
    '........',
  ];

  static const heart = [
    '.oo.oo.',
    'oRRoRRo',
    'oRRRRRo',
    '.oRRRo.',
    '..oRo..',
    '...o...',
  ];
  static const Map<String, Color> heartFullPalette = {
    'o': SnesPalette.outline,
    'R': SnesPalette.heart,
  };
  static const Map<String, Color> heartEmptyPalette = {
    'o': SnesPalette.outline,
    'R': SnesPalette.heartEmpty,
  };

  // ---------- Ground tile (16x16) ----------
  static const grassTile = [
    'gggggggggggggggg',
    'ggggggggggggdggg',
    'gglggggggggggggg',
    'gldlgggggggggggg',
    'gggggggggggggggg',
    'ggggggdggggggggg',
    'gggggggggggglggg',
    'gggggggggggldlgg',
    'gggggggggggggggg',
    'gdgggggggggggggg',
    'gggggggggggggggg',
    'gggggglggggggdgg',
    'gggggldlgggggggg',
    'gggggggggggggggg',
    'ggggggggggggggdg',
    'gggggggggggggggg',
  ];
  static const Map<String, Color> grassPalette = {
    'g': SnesPalette.grass,
    'd': SnesPalette.grassDark,
    'l': SnesPalette.grassLight,
  };
}
