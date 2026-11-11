import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:first_app_flutter/game/iso/gothic.dart';
import 'package:first_app_flutter/game/game_page.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  static MaterialPageRoute route() {
    return MaterialPageRoute<void>(
      builder: (_) => const TitleScreen(),
    );
  }

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  late final FocusNode _focusNode = FocusNode();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _focusNode.requestFocus();

    manageAudio();
  }

  Future<void> manageAudio() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.load('music.ogg');
    FlameAudio.bgm.play('music.ogg', volume: 0.5);
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  void _startGame() {
    if (_isNavigating) return;
    _isNavigating = true;
    Navigator.of(context).push(GamePage.route()).then((_) {
      _isNavigating = false;
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        _startGame();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _startGame,
        child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black,
                child: Image.asset(
                  'assets/images/zombie_wallpaper.jpg',
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Image.asset(
                        'assets/images/ready.jpg',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        height: 200,
                        width: 400,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Press any button or tap to play',
                        textAlign: TextAlign.center,
                        style: Gothic.font(size: 22, color: Gothic.gold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
