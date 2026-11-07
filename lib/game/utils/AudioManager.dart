import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isPreloaded = false;
  Future<void>? _preloadFuture;

  Future<void> preloadSounds() {
    if (_isPreloaded) return Future.value();
    _preloadFuture ??= FlameAudio.audioCache
        .loadAll(['zombie_cri.ogg', 'pan.ogg', 'explosed.ogg'])
        .then((_) => _isPreloaded = true);
    return _preloadFuture!;
  }

  void playZombieSound() {
    if (!_isPreloaded) return;
    FlameAudio.play('zombie_cri.ogg', volume: 0.5);
  }

  void playPanSound() {
    if (!_isPreloaded) return;
    FlameAudio.play('pan.ogg', volume: 0.5);
  }

  void playExplosedSound() {
    if (!_isPreloaded) return;
    FlameAudio.play('explosed.ogg', volume: 0.5);
  }
}
