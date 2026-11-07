import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) {
        if (_isNavigating) return;
        if (event is! RawKeyDownEvent) return;
        _isNavigating = true;
        Navigator.of(context).push(GamePage.route()).then((_) {
          _isNavigating = false;
          _focusNode.requestFocus();
        });
      },
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
                        'Press any button to play',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 16,
                          color: const Color(0xff61d3e3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
