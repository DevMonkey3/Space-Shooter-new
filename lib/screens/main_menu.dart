import 'package:flutter/material.dart';

import '../models/firebase.dart';
import '../models/id_storage.dart';
import '../widgets/title_text.dart';
import 'create_account.dart';
import 'leaderboard_screen.dart';
import 'select_spaceship.dart';
import 'settings_menu.dart';

// Represents the main menu screen of Space Shooter 2400, allowing
// players to start the game or modify in-game settings.
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  Future<void> _play(BuildContext context) async {
    // New players with online features available create an account
    // first; everyone else goes straight to the hangar.
    var needsAccount = false;
    if (FireBase.isAvailable) {
      final id = await IDStorage().readID();
      needsAccount = id.isEmpty;
    }
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            needsAccount ? const CreateAccount() : const SelectSpaceship(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TitleText('Space\nShooter\n2400'),

            // Play button.
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () => _play(context),
                child: const Text('Play'),
              ),
            ),

            // Scoreboard button.
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LeaderboardScreen(),
                    ),
                  );
                },
                child: const Text('Scoreboard'),
              ),
            ),

            // Settings button.
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsMenu(),
                    ),
                  );
                },
                child: const Text('Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
