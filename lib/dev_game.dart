import 'package:first_app_flutter/game/game_page.dart';
import 'package:flutter/material.dart';

/// Dev entry: opens the game directly (skips the title screen).
/// flutter run -d linux -t lib/dev_game.dart
void main() => runApp(const MaterialApp(home: GamePage()));
