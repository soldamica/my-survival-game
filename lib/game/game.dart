import 'dart:math';

import 'package:first_app_flutter/game/components/components.dart';
import 'package:first_app_flutter/game/iso/character_sheet.dart';
import 'package:first_app_flutter/game/iso/gothic.dart';
import 'package:first_app_flutter/game/iso/iso.dart';
import 'package:first_app_flutter/game/utils/AudioManager.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SurvivalGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  SurvivalGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: Iso.viewWidth,
            height: Iso.viewHeight,
          ),
        );

  int bullets = 0;
  int score = 0;
  int wave = 1;
  bool endOfGame = false;
  bool controlsLocked = false;

  /// Hero position on the ground plane (logic) and in world (screen) space.
  final Vector2 playerGround = Vector2.zero();
  final Vector2 playerPosition = Vector2.zero();

  /// Where the hero's feet appear in the viewport (camera anchor).
  Vector2 get heroScreenAnchor =>
      Vector2(Iso.viewWidth / 2, (Iso.viewHeight - Hud.panelHeight) * 0.55);

  final Random _random = Random();
  final CharacterSheet _heroSheet = CharacterSheet();
  final CharacterSheet _zombieSheet = CharacterSheet();

  static const int _maxAliveZombies = 12;
  static const int _maxWave = 6;

  static const _images = [
    'iso/floor_0.png', 'iso/floor_1.png', 'iso/floor_2.png', 'iso/floor_3.png',
    'iso/shadow.png', 'iso/arrow.png', 'iso/arrow_pickup.png', 'iso/sword_pickup.png',
    'iso/hud_panel.png', 'iso/orb_frame.png', 'iso/orb_red.png', 'iso/orb_blue.png',
    'iso/skill_bow.png', 'iso/skill_sword.png',
  ];

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await images.loadAll(_images);
    await _heroSheet.load(this, 'iso/hero.png', stepTime: 0.08);
    await _zombieSheet.load(this, 'iso/zombie.png', stepTime: 0.14);

    world.addAll([
      Background(),
      GunIcon(Vector2(-60, 40)),
      GunIcon(Vector2(90, -30)),
      SwordIcon(Vector2(120, 120)),
    ]);

    final player = Player(Vector2.zero(), _heroSheet);
    world.add(player);

    // Camera follows the hero, placed above the HUD panel.
    camera.viewfinder.anchor = Anchor(
      heroScreenAnchor.x / Iso.viewWidth,
      heroScreenAnchor.y / Iso.viewHeight,
    );
    camera.follow(player);

    camera.viewport.addAll([LightRadius(), Hud()]);
    if (kDebugMode) {
      camera.viewport.add(FpsTextComponent(position: Vector2(4, 4), scale: Vector2.all(0.5)));
    }
    if (_isMobile) _addTouchControls(player);

    createWave();
    await AudioManager().preloadSounds();
  }

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void _addTouchControls(Player player) {
    final joystick = JoystickComponent(
      priority: 200,
      knob: CircleComponent(
        radius: 12,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.5),
      ),
      background: CircleComponent(
        radius: 30,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.15),
      ),
      margin: const EdgeInsets.only(left: 80, bottom: Hud.panelHeight + 12),
    );

    final shootButton = HudButtonComponent(
      priority: 200,
      button: CircleComponent(
        radius: 20,
        paint: Paint()..color = Gothic.blood.withValues(alpha: 0.5),
      ),
      buttonDown: CircleComponent(
        radius: 20,
        paint: Paint()..color = Gothic.blood.withValues(alpha: 0.85),
      ),
      margin: const EdgeInsets.only(right: 80, bottom: Hud.panelHeight + 16),
      onPressed: () {
        if (canProcessInput()) player.shoot();
      },
    );

    player.joystick = joystick;
    camera.viewport.addAll([joystick, shootButton]);
  }

  int _countAliveZombies() =>
      world.children.whereType<Zombie>().where((z) => !z.isReallyDead).length;

  /// Spawns zombies on the arena border.
  Future<void> createWave() async {
    final alive = _countAliveZombies();
    if (alive >= _maxAliveZombies) return;

    final toSpawn = min(wave, _maxAliveZombies - alive);
    const edge = Iso.arena - 8;
    for (int i = 0; i < toSpawn; i++) {
      final t = _random.nextDouble() * 2 * edge - edge;
      final spawn = switch (_random.nextInt(4)) {
        0 => Vector2(-edge, t),
        1 => Vector2(edge, t),
        2 => Vector2(t, -edge),
        _ => Vector2(t, edge),
      };
      world.add(Zombie('leZombie', spawn, _zombieSheet));
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }

    if (wave < _maxWave) wave += 1;
  }

  void evalNextWave() {
    if (!hasRobot()) createWave();
  }

  bool hasRobot() => _countAliveZombies() > 0;

  bool canProcessInput() => !controlsLocked && !endOfGame;

  void showPopup() => overlays.add('GameOver');

  void hidePopup() => overlays.remove('GameOver');

  void restart() {
    overlays.remove('GameOver');
    endOfGame = false;
    controlsLocked = false;
    resumeEngine();
  }

  Future<void> finishGame(Vector2 lastPosition) async {
    if (endOfGame) return;
    endOfGame = true;
    controlsLocked = true;
    world.add(Blood(lastPosition));
    await Future<void>.delayed(const Duration(seconds: 1));
    showPopup();
    FlameAudio.bgm.stop();
    pauseEngine();
  }
}
