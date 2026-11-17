import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

import '../models/firebase.dart';
import '../models/id_storage.dart';
import '../models/player_data.dart';
import '../models/spaceship_details.dart';
import '../widgets/title_text.dart';

import 'game_play.dart';
import 'leaderboard_screen.dart';
import 'main_menu.dart';

// Represents the spaceship selection menu from where player can
// change current spaceship or buy a new one.
class SelectSpaceship extends StatefulWidget {
  const SelectSpaceship({super.key});

  @override
  State<SelectSpaceship> createState() => _SelectSpaceshipState();
}

class _SelectSpaceshipState extends State<SelectSpaceship> {
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    if (!FireBase.isAvailable) return;
    try {
      final id = await IDStorage().readID();
      final account = await FireBase().getAccount(id);
      if (account != null && mounted) {
        setState(() => _username = account.name);
      }
    } catch (_) {
      // Offline or account missing: just show the generic greeting.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Greeting.
            TitleText(
              _username == null ? 'Welcome Back' : 'Welcome Back\n$_username',
              fontSize: 32,
            ),

            // Displays current spaceship's name and amount of money left.
            Consumer<PlayerData>(
              builder: (context, playerData, child) {
                final spaceship =
                    Spaceship.getSpaceshipByType(playerData.spaceshipType);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Ship: ${spaceship.name}'),
                    Text('Money: ${playerData.money}'),
                  ],
                );
              },
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: CarouselSlider.builder(
                itemCount: Spaceship.spaceships.length,
                slideBuilder: (index) {
                  final spaceship =
                      Spaceship.spaceships.entries.elementAt(index).value;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(spaceship.assetPath),
                      Text(spaceship.name),
                      Text('Speed: ${spaceship.speed}'),
                      Text('Level: ${spaceship.level}'),
                      Text('Cost: ${spaceship.cost}'),
                      Consumer<PlayerData>(
                        builder: (context, playerData, child) {
                          final type =
                              Spaceship.spaceships.entries.elementAt(index).key;
                          final isEquipped = playerData.isEquipped(type);
                          final isOwned = playerData.isOwned(type);
                          final canBuy = playerData.canBuy(type);

                          return ElevatedButton(
                            onPressed: isEquipped
                                ? null
                                : () {
                                    if (isOwned) {
                                      playerData.equip(type);
                                    } else {
                                      if (canBuy) {
                                        playerData.buy(type);
                                      } else {
                                        // Displays an alert if player
                                        // does not have enough money.
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.red,
                                              title: const Text(
                                                'Insufficient Balance',
                                                textAlign: TextAlign.center,
                                              ),
                                              content: Text(
                                                'Need ${spaceship.cost - playerData.money} more',
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    }
                                  },
                            child: Text(
                              isEquipped
                                  ? 'Equipped'
                                  : isOwned
                                      ? 'Select'
                                      : 'Buy',
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Start button.
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                onPressed: () {
                  // Push and replace current screen (i.e MainMenu) with
                  // GamePlay, because back press will be blocked by GamePlay.
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const GamePlay(),
                    ),
                  );
                },
                child: const Text('Start'),
              ),
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
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

            // Back button.
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainMenu(),
                    ),
                  );
                },
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
