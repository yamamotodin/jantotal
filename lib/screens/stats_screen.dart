import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../models/player.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Player? _selectedPlayer;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('統計'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: provider.players.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('プレイヤーが登録されていません',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'プレイヤーを選択',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Player>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'プレイヤーを選択してください',
                      ),
                      value: _selectedPlayer,
                      items: provider.players.map((player) {
                        return DropdownMenuItem(
                          value: player,
                          child: Text(player.name),
                        );
                      }).toList(),
                      onChanged: (player) {
                        setState(() {
                          _selectedPlayer = player;
                        });
                      },
                    ),
                    if (_selectedPlayer != null) ...[
                      const SizedBox(height: 24),
                      _buildPlayerStats(provider, _selectedPlayer!),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlayerStats(AppProvider provider, Player player) {
    return FutureBuilder<Map<String, dynamic>>(
      future: provider.getPlayerStats(player.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        final totalGames = stats['totalGames'] as int;
        final totalScore = stats['totalScore'] as int;
        final averageScore = stats['averageScore'] as double;
        final rankings = stats['rankings'] as List<int>;
        final averageRank = stats['averageRank'] as double;

        if (totalGames == 0) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('まだ対局記録がありません'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${player.name}の統計',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatCard('総対局数', '$totalGames局'),
            _buildStatCard('総収支', totalScore >= 0 ? '+$totalScore' : '$totalScore'),
            _buildStatCard('平均収支', averageScore.toStringAsFixed(1)),
            _buildStatCard('平均順位', averageRank.toStringAsFixed(2)),
            const SizedBox(height: 24),
            const Text(
              '順位分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRankingTable(rankings, totalGames),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingTable(List<int> rankings, int totalGames) {
    final colors = [
      Colors.amber[700]!,
      Colors.grey[400]!,
      Colors.orange[300]!,
      Colors.blue[300]!,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '順位詳細',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (index) {
              final count = rankings[index];
              final percentage = (count / totalGames * 100).toStringAsFixed(1);
              final barWidth = count / totalGames;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${index + 1}位',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('$count回 ($percentage%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: barWidth,
                        minHeight: 20,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(colors[index]),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
