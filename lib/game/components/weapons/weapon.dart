
/// Weapons the hero can switch between.
enum Weapon {
  sword('ÉPÉE', 'iso/skill_sword.png'),
  bow('ARC', 'iso/skill_bow.png');

  const Weapon(this.label, this.icon);

  final String label;
  final String icon;

  Weapon get next => Weapon.values[(index + 1) % Weapon.values.length];
}