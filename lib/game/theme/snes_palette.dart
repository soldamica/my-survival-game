import 'dart:ui';

/// Palette 16-bit partagée. Toujours utiliser ces couleurs.
class SnesPalette {
  SnesPalette._();

  // Contours / ombres
  static const outline = Color(0xFF1A1424);
  static const shadow = Color(0x55000000);

  // Herbe & terrain
  static const grassDark = Color(0xFF3A7D2C);
  static const grass = Color(0xFF58A83A);
  static const grassLight = Color(0xFF8CD05A);
  static const dirtDark = Color(0xFF8A5A2B);
  static const dirt = Color(0xFFC08A4A);
  static const dirtLight = Color(0xFFE0B878);
  static const stone = Color(0xFF8C8C9C);
  static const bush = Color(0xFF26602A);

  // Héros
  static const heroTunic = Color(0xFF2E8B3A);
  static const heroTunicLight = Color(0xFF5CC85A);
  static const skin = Color(0xFFF4C090);
  static const hair = Color(0xFFE0A030);
  static const leather = Color(0xFF7A4A22);

  // Zombie
  static const zombieSkin = Color(0xFF7FA05A);
  static const zombieSkinDark = Color(0xFF4E6A38);
  static const zombieCloth = Color(0xFF5A3C78);
  static const zombieClothLight = Color(0xFF8A64B0);
  static const zombieEye = Color(0xFFE8E040);

  // Projectiles / armes
  static const wood = Color(0xFFA06A30);
  static const metal = Color(0xFFD0D8E0);
  static const feather = Color(0xFFF0F0F0);
  static const blood = Color(0xFFB01828);
  static const bloodDark = Color(0xFF6A0A18);

  // HUD
  static const hudFrame = Color(0xFFF8E8A0);
  static const hudFrameDark = Color(0xFFA08838);
  static const hudBg = Color(0xCC101020);
  static const heart = Color(0xFFE82838);
  static const heartEmpty = Color(0xFF503848);
  static const lifeLabel = Color(0xFFE85030);
  static const gold = Color(0xFFF8C830);
  static const text = Color(0xFFF8F8F8);
}
