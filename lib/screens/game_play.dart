import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/game.dart';
import '../widgets/overlays/game_over_menu.dart';
import '../widgets/overlays/pause_button.dart';
import '../widgets/overlays/pause_menu.dart';

// Creating this as a file private object so as to
// avoid unwanted rebuilds of the whole game object.
final SpaceShooterGame _spaceshooterGame = SpaceShooterGame();

// This class represents the actual game screen
// where all the action happens.
class GamePlay extends StatelessWidget {
  const GamePlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PopScope blocks the system back button while playing;
      // use the pause menu to leave the game instead.
      body: PopScope(
        canPop: false,
        // GameWidget is useful to inject the underlying
        // widget of any class extending from Flame's Game class.
        child: GameWidget(
          game: _spaceshooterGame,
          // Initially only pause button overlay will be visible.
          initialActiveOverlays: const [PauseButton.id],
          overlayBuilderMap: {
            PauseButton.id: (BuildContext context, SpaceShooterGame game) =>
                PauseButton(game: game),
            PauseMenu.id: (BuildContext context, SpaceShooterGame game) =>
                PauseMenu(game: game),
            GameOverMenu.id: (BuildContext context, SpaceShooterGame game) =>
                GameOverMenu(game: game),
          },
        ),
      ),
    );
  }
}
