import 'package:flame_audio/flame_audio.dart';

/// Weapons the hero can switch between.
enum Weapon {
  sword('ÉPÉE', 'sword.png', 'sword.mp3'),
  bow('ARC', 'iso/skill_bow.png', 'bow.mp3');

  const Weapon(this.label, this.icon, this.sound);

  final String label;
  final String icon;

  /// Son joué quand le héros utilise l'arme (dans assets/audio/).
  final String sound;

  /// Joue le son de l'arme.
  void playSound() => FlameAudio.play(sound, volume: 0.5);

  Weapon get next => Weapon.values[(index + 1) % Weapon.values.length];
}