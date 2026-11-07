import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:first_app_flutter/game/game.dart';

import 'components/game_over_overlay.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  static MaterialPageRoute route() {
    return MaterialPageRoute<void>(
      builder: (_) => const GamePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget<SurvivalGame>.controlled(
      gameFactory: () {
        final game = SurvivalGame();
        // game.debugMode = kDebugMode;
        return game;
      },
      overlayBuilderMap: {
        'GameOver': (context, game) => GameOverOverlay(game: game),
        if (kDebugMode)
          'Performance': (context, game) => const Positioned(
                top: 0,
                left: 0,
                child: PerformanceOverlay(),
              ),
      },
    );
  }
}
