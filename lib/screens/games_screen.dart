import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../models/game.dart';
import 'game_detail_screen.dart';
import 'new_game_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('対局履歴'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.games.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('対局履歴がありません',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  const Text('下のボタンから対局を記録してください',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.games.length,
            itemBuilder: (context, index) {
              final game = provider.games[index];
              return _buildGameCard(context, game, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NewGameScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Game game, AppProvider provider) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final totalScores = game.getTotalScores();
    final rankings = game.getRankings();

    // 順位順にソート
    final sortedPlayers = game.playerIds.toList()
      ..sort((a, b) => rankings[a]!.compareTo(rankings[b]!));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameDetailScreen(game: game),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(game.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${game.rounds.length}局',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...sortedPlayers.asMap().entries.map((entry) {
                final rank = entry.key;
                final playerId = entry.value;
                final player = provider.getPlayerById(playerId);
                final score = totalScores[playerId] ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${rank + 1}位',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rank == 0 ? Colors.amber[700] : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(player?.name ?? '不明'),
                      ),
                      Text(
                        score >= 0 ? '+$score' : '$score',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: score >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
