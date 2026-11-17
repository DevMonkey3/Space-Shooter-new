import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game.dart';
import '../../models/player_data.dart';
import '../../screens/main_menu.dart';
import 'pause_button.dart';

// This class represents the game over menu overlay.
class GameOverMenu extends StatelessWidget {
  static const String id = 'GameOverMenu';
  final SpaceShooterGame game;

  const GameOverMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pause menu title.
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text(
              'Game Over',
              style: TextStyle(
                fontSize: 50.0,
                color: Colors.black,
                shadows: [
                  Shadow(
                    blurRadius: 20.0,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  )
                ],
              ),
            ),
          ),

          // Final score of this round and best score so far.
          Consumer<PlayerData>(
            builder: (context, playerData, child) => Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Score: ${playerData.currentScore}\n'
                'Best: ${playerData.highScore}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
          ),

          // Restart button.
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                game.overlays.remove(GameOverMenu.id);
                game.overlays.add(PauseButton.id);
                game.reset();
                game.resumeEngine();
              },
              child: const Text('Restart'),
            ),
          ),

          // Exit button.
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                game.overlays.remove(GameOverMenu.id);
                game.reset();
                game.resumeEngine();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainMenu(),
                  ),
                );
              },
              child: const Text('Exit'),
            ),
          ),
        ],
      ),
    );
  }
}
