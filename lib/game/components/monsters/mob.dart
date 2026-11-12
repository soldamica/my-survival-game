import 'package:first_app_flutter/game/components/bullet.dart';
import 'package:first_app_flutter/game/components/player.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/character_sheet.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:first_app_flutter/game/iso/iso_body.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

enum _State { chase, attack, recover }

/// Monstre générique. Marche vers le héros, s'arrête juste avant de le
/// toucher, joue son animation d'attaque et inflige [attack] dégâts au héros
/// s'il est encore dans la zone devant lui à la fin de l'animation.
///
/// Les implémentations fournissent les sprites, les PV et l'attaque.
abstract class Mob extends SpriteAnimationComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks, IsoBody {
  Mob(this.name, Vector2 startGround)
      : super(
          size: Vector2.all(CharacterSheet.frame),
          anchor: CharacterSheet.feet,
        ) {
    ground.setFrom(startGround);
  }

  final String name;
  bool isReallyDead = false;

  /// Sprite de mouvement.
  CharacterSheet get sheet;

  /// Sprite d'attaque.
  CharacterSheet get attackSheet;

  /// Points de vie maximum.
  double get maxHp;

  /// Dégâts infligés au héros par frappe.
  double get attack;

  /// Points de vie courants.
  late double hp = maxHp;

  /// Ground units per second.
  double get speed => 64.0;

  /// Stops (and attacks) when the hero is this close on screen (px).
  double get stopDistance => 60.0;

  /// Attack reach on screen (px), measured from the mob's feet.
  double get attackReach => 90.0;

  /// Cone in front of the mob: cos of the half-angle (0.3 ≈ ±72°).
  double get attackCone => 0.3;

  /// Pause after a strike before chasing/attacking again (s).
  double get recoverTime => 0.6;

  /// Son joué à l'apparition.
  void playSpawnSound() {}

  /// Son joué à la mort.
  void playDeathSound() {}

  _State _state = _State.chase;
  double _timer = 0;
  int _row = 0;

  /// Screen direction locked at the start of the attack.
  final Vector2 _attackDir = Vector2(0, 1);
  late final Sprite _shadow;

  @override
  Future<void> onLoad() async {
    playSpawnSound();
    animation = sheet.row(_row);
    _shadow = Sprite(game.images.fromCache('iso/shadow.png'));
    // Lower body only; used for arrows.
    add(RectangleHitbox(position: Vector2(34, 40), size: Vector2(28, 48)));
    syncIso();
  }

  @override
  void render(Canvas canvas) {
    renderShadow(canvas, _shadow);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (game.endOfGame) return;
    super.update(dt);

    final toHero = Iso.deltaToScreen(game.playerGround - ground);
    final dist = toHero.length;

    switch (_state) {
      case _State.chase:
        if (dist <= stopDistance) {
          _startAttack(toHero);
        } else {
          final dir = (game.playerGround - ground).normalized();
          ground.add(dir * speed * dt);
          _face(Iso.deltaToScreen(dir), attacking: false);
        }
      case _State.attack:
        _timer -= dt;
        if (_timer <= 0) {
          _strike(toHero, dist);
          _state = _State.recover;
          _timer = recoverTime;
          animation = sheet.row(_row);
          playing = false;
        }
      case _State.recover:
        _timer -= dt;
        if (_timer <= 0) {
          _state = _State.chase;
          playing = true;
        }
    }
    syncIso();
  }

  void _face(Vector2 screenDir, {required bool attacking}) {
    final row = Iso.dirRow(screenDir, _row);
    if (row != _row || attacking) {
      _row = row;
      animation = (attacking ? attackSheet : sheet).row(row);
    }
  }

  void _startAttack(Vector2 toHero) {
    _state = _State.attack;
    _timer = attackSheet.duration;
    if (!toHero.isZero()) _attackDir.setFrom(toHero.normalized());
    _face(_attackDir, attacking: true);
    animationTicker?.reset();
    playing = true;
  }

  /// Fin de l'animation : le héros subit des dégâts s'il est encore devant, à portée.
  void _strike(Vector2 toHero, double dist) {
    if (dist > attackReach) return;
    if (dist > 16 && _attackDir.dot(toHero / dist) < attackCone) return;
    final hero = game.world.children.whereType<Player>().firstOrNull;
    if (hero == null || hero.isDead) return;
    hero.takeDamage(attack);
  }

  /// Reçoit des dégâts (flèche, épée...).
  void takeDamage(double amount) {
    if (isReallyDead) return;
    hp = (hp - amount).clamp(0, maxHp).toDouble();
    if (hp <= 0) die();
  }

  /// Tué par une flèche ou un coup d'épée.
  void die() {
    if (isReallyDead) return;
    isReallyDead = true;
    hp = 0;
    removeFromParent();
    playDeathSound();
    game.score++;
    game.evalNextWave();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (!isReallyDead && other is Bullet) {
      final hero = game.world.children.whereType<Player>().firstOrNull;
      takeDamage(hero?.attackPower ?? 50);
    }
  }
}

