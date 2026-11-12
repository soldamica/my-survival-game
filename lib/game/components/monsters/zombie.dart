import 'package:first_app_flutter/game/components/bullet.dart';
import 'package:first_app_flutter/game/components/player.dart';
import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/character_sheet.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:first_app_flutter/game/iso/iso_body.dart';
import 'package:first_app_flutter/game/utils/AudioManager.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

enum _State { chase, attack, recover }

/// Goblin (pike). Walks to the hero, stops just before touching him,
/// plays its attack animation, and kills the hero only if he is still in
/// the zone in front of it when the strike lands (end of the animation).
class Zombie extends SpriteAnimationComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks, IsoBody {
  Zombie(this.name, Vector2 startGround, this.sheet, this.attackSheet)
      : super(
          size: Vector2.all(CharacterSheet.frame),
          anchor: CharacterSheet.feet,
        ) {
    ground.setFrom(startGround);
  }

  final String name;
  final CharacterSheet sheet;
  final CharacterSheet attackSheet;
  bool isReallyDead = false;

  /// Points de vie.
  double maxHp = 100;
  double hp = 100;

  /// Dégâts infligés au héros par frappe.
  double attack = 25;

  /// Reçoit des dégâts (flèche, épée...).
  void takeDamage(double amount) {
    if (isReallyDead) return;
    hp = (hp - amount).clamp(0, maxHp).toDouble();
    if (hp <= 0) die();
  }

  /// Ground units per second.
  static const _speed = 64.0;

  /// Stops (and attacks) when the hero is this close on screen (px).
  static const _stopDistance = 60.0;

  /// Pike reach on screen (px), measured from the goblin's feet.
  static const _attackReach = 90.0;

  /// Cone in front of the goblin: cos of the half-angle (0.3 ≈ ±72°).
  static const _attackCone = 0.3;

  /// Pause after a strike before chasing/attacking again (s).
  static const _recoverTime = 0.6;

  _State _state = _State.chase;
  double _timer = 0;
  int _row = 0;

  /// Screen direction locked at the start of the attack.
  final Vector2 _attackDir = Vector2(0, 1);
  late final Sprite _shadow;

  @override
  Future<void> onLoad() async {
    AudioManager().playZombieSound();
    animation = sheet.row(_row);
    _shadow = Sprite(game.images.fromCache('iso/shadow.png'));
    // Lower body only; only used for arrows now (no contact kill).
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
        if (dist <= _stopDistance) {
          _startAttack(toHero);
        } else {
          final dir = (game.playerGround - ground).normalized();
          ground.add(dir * _speed * dt);
          _face(Iso.deltaToScreen(dir), attacking: false);
        }
      case _State.attack:
        _timer -= dt;
        if (_timer <= 0) {
          _strike(toHero, dist);
          _state = _State.recover;
          _timer = _recoverTime;
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

  /// End of the animation: the hero dies if he is still in front, in reach.
  void _strike(Vector2 toHero, double dist) {
    if (dist > _attackReach) return;
    if (dist > 16 && _attackDir.dot(toHero / dist) < _attackCone) return;
    final hero = game.world.children.whereType<Player>().firstOrNull;
    if (hero == null || hero.isDead) return;
    hero.takeDamage(attack);
  }

  /// Killed by an arrow or a sword hit.
  void die() {
    if (isReallyDead) return;
    isReallyDead = true;
    removeFromParent();
    AudioManager().playExplosedSound();
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
