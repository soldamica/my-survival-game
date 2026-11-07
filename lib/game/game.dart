import 'dart:math';

import 'package:first_app_flutter/game/components/components.dart';
import 'package:first_app_flutter/game/utils/AudioManager.dart';
import 'package:first_app_flutter/game/utils/heroes_sprite_preloader.dart';
import 'package:first_app_flutter/game/utils/zombie_sprite_preloader.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'RightPanel.dart';

class SurvivalGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {

  int bullets = 0;
  int score = 0;
  int wave = 1;
  late TextComponent infoComponent;
  bool hasBlood = false;
  bool endOfGame = false;
  Vector2 playerPosition = Vector2.zero();

  final Random _random = Random();

  static const int _maxAliveZombies = 12;
  static const int _maxWave = 6;

  SurvivalGame()
      : super(
          children: [
            Background(),
            GunIcon(Vector2(500,500)),
            GunIcon(Vector2(800,500)),
            SwordIcon(Vector2(1000,500)),
          ],
        );



  @override
  Future<void> onLoad() async {
    super.onLoad();

    final sprite = await loadSprite('empty.jpeg');

    add(
      RightPanel(
        label: 'Label',
        iconSprite: sprite,
      ),
    );

    add(FpsTextComponent(position: Vector2(10, 10)));
    //overlays.add('Performance');

    HeroesSpritePreloader heroesSpritePreloader = HeroesSpritePreloader(game: this);
    await heroesSpritePreloader.preloadAnimations(4);
    add(Player(size / 2, heroesSpritePreloader));

    final screenSize = size;
    final relativeX = 300.0; //TODO : position relative?
    final relativeY = screenSize.y - 100;

    createInfoComponent('Bullets : $bullets', relativeX, relativeY);
    createInfoComponent('Score : $score', relativeX, relativeY);

    ZombieSpritePreloader zombieSpritePreloader = ZombieSpritePreloader(game: this);
    await zombieSpritePreloader.preloadAnimations(4);
    createWave(zombieSpritePreloader);

    add(infoComponent);

    await AudioManager().preloadSounds();
  }

  int _countAliveZombies() {
    int count = 0;
    for (final c in children) {
      if (c is Zombie && !c.isReallyDead) count++;
    }
    return count;
  }

  Future<void> createWaveAsync(ZombieSpritePreloader zombieSpritePreloader) async {
    final alive = _countAliveZombies();
    if (alive >= _maxAliveZombies) return;

    final toSpawn = min(wave, _maxAliveZombies - alive);
    for (int i = 0; i < toSpawn; i++) {
      final x = _random.nextDouble() * size.x;
      final y = _random.nextDouble() * size.y;
      add(
        Zombie(
          "leZombie",
          Vector2(computeStartX(x), computeStartY(y)),
          zombieSpritePreloader,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 40)); // lisse la charge
    }

    if (wave < _maxWave) {
      wave += 1; // progression plus douce que x2
    }
  }

  void createWave(ZombieSpritePreloader zombieSpritePreloader) {
    // garde la signature existante si utilisée ailleurs
    createWaveAsync(zombieSpritePreloader);
  }

  void createInfoComponent(String myText, double relativeX, double relativeY) {
    infoComponent = TextComponent(
      text: myText,
      position: Vector2(relativeX, relativeY),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
  }

  void updateText() {
    infoComponent.text = 'Bullets : $bullets, Score : $score';
  }

  void showPopup() {
    overlays.add('GameOver');
  }

  void hidePopup() {
    overlays.remove('GameOver');
  }

  void restart() {
    overlays.remove('GameOver');
    resumeEngine();
  }

  double computeStartX(double value) {
    const margin = 8.0; // avant: 100.0
    return value < (size.x / 2) ? margin : size.x - margin;
  }

  double computeStartY(double value) {
    const margin = 8.0; // avant: 100.0
    return value < (size.y / 2) ? margin : size.y - margin;
  }

  void evalNextWave(ZombieSpritePreloader zombieSpritePreloader){
    if(!hasRobot()){
      createWave(zombieSpritePreloader);
    }
  }

  bool hasRobot() {
    for (Component component in children) {
      if (component is Zombie && !component.isReallyDead) {
        return true;
      }
    }
    return false;
  }

  void finishGame(Vector2 lastPosition) async {
    await showBlood(lastPosition);
    showPopup();
    FlameAudio.bgm.stop();
    pauseEngine();
  }

  Future<void> showBlood(Vector2 lastPosition) async {
    final endBlood = Blood(lastPosition);
    add(endBlood);
    return Future.delayed(const Duration(seconds: 1));
  }
}
