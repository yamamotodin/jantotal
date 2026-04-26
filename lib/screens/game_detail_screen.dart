import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../services/app_provider.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final totalScores = game.getTotalScores();
    final rankings = game.getRankings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('対局詳細'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(game.date),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '最終結果',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildFinalResults(provider, totalScores, rankings),
              const SizedBox(height: 24),
              const Text(
                '局ごとの詳細',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...game.rounds.asMap().entries.map((entry) {
                return _buildRoundCard(provider, entry.value);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalResults(
      AppProvider provider, Map<String, int> totalScores, Map<String, int> rankings) {
    final sortedPlayers = game.playerIds.toList()
      ..sort((a, b) => rankings[a]!.compareTo(rankings[b]!));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: sortedPlayers.asMap().entries.map((entry) {
            final rank = entry.key;
            final playerId = entry.value;
            final player = provider.getPlayerById(playerId);
            final score = totalScores[playerId] ?? 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${rank + 1}位',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: rank == 0 ? Colors.amber[700] : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      player?.name ?? '不明',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    score >= 0 ? '+$score' : '$score',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: score >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoundCard(AppProvider provider, round) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第${round.roundNumber}局',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...game.playerIds.map((playerId) {
              final player = provider.getPlayerById(playerId);
              final score = round.scores[playerId] ?? 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
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
            if (round.notes != null && round.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'メモ: ${round.notes}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('対局削除'),
          content: const Text('この対局を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final provider = Provider.of<AppProvider>(context, listen: false);
                provider.deleteGame(game.id);
                Navigator.of(context).pop(); // ダイアログを閉じる
                Navigator.of(context).pop(); // 詳細画面を閉じる
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }
}
