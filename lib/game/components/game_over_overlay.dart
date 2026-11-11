import 'dart:io';

import 'package:first_app_flutter/game/game.dart';
import 'package:first_app_flutter/game/iso/gothic.dart';
import 'package:flutter/material.dart';

/// Death screen, gothic style.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final SurvivalGame game;

  @override
  Widget build(BuildContext context) {
    Widget button(String label, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Gothic.stone,
              border: Border.all(color: Gothic.goldDark, width: 2),
            ),
            child: Text(label, style: Gothic.font(size: 18, color: Gothic.gold)),
          ),
        );

    return ColoredBox(
      color: const Color(0xAA000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('VOUS ÊTES MORT', style: Gothic.font(size: 48, color: Gothic.blood)),
            const SizedBox(height: 8),
            Text('${game.score} zombies tués', style: Gothic.font(size: 18)),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                button('Ré-essayer', () => Navigator.of(context).pop()),
                button('Quitter', () => exit(0)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
