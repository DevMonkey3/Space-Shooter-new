import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/account.dart';
import '../models/firebase.dart';
import '../models/id_storage.dart';
import '../models/player_data.dart';
import '../widgets/title_text.dart';

// Shows the online top-20 scoreboard, highlighting the current player.
// Falls back to the local high score when playing offline.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Stream<List<Account>>? _scores;
  String _myId = '';

  @override
  void initState() {
    super.initState();
    if (FireBase.isAvailable) {
      _scores = FireBase().topScores();
      IDStorage().readID().then((id) {
        if (mounted) setState(() => _myId = id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final highScore = context.select<PlayerData, int>((p) => p.highScore);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TitleText('Scoreboard', fontSize: 40),
            Text('Your best: $highScore'),
            const SizedBox(height: 16),
            Expanded(child: _buildList()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final scores = _scores;
    if (scores == null) {
      return const _Message(
        'Online scoreboard unavailable.\nYou are playing offline.',
      );
    }
    return StreamBuilder<List<Account>>(
      stream: scores,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _Message('Could not load the scoreboard.');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final accounts = snapshot.data!;
        if (accounts.isEmpty) {
          return const _Message('No scores yet.\nBe the first!');
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            final isMe = account.id == _myId;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.blue.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(width: 40, child: Text('${index + 1}.')),
                  Expanded(
                    child: Text(account.name, overflow: TextOverflow.ellipsis),
                  ),
                  Text('${account.score}'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  const _Message(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, textAlign: TextAlign.center));
  }
}
