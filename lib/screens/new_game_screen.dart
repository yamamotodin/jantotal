import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/round.dart';
import '../models/player.dart';
import '../services/app_provider.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final List<Player?> _selectedPlayers = [null, null, null, null];
  final List<Round> _rounds = [];
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規対局'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: [
          Step(
            title: const Text('プレイヤー選択'),
            content: _buildPlayerSelection(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('点数記録'),
            content: _buildScoreInput(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('確認'),
            content: _buildConfirmation(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSelection() {
    final provider = Provider.of<AppProvider>(context);

    if (provider.players.length < 4) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '対局を記録するには、最低4人のプレイヤーが必要です。\nプレイヤー管理画面からプレイヤーを追加してください。',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: DropdownButtonFormField<Player>(
            decoration: InputDecoration(
              labelText: '${index + 1}人目',
              border: const OutlineInputBorder(),
            ),
            value: _selectedPlayers[index],
            items: provider.players.map((player) {
              return DropdownMenuItem(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            onChanged: (player) {
              setState(() {
                _selectedPlayers[index] = player;
              });
            },
          ),
        );
      }),
    );
  }

  Widget _buildScoreInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '現在: ${_rounds.length}局目',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _showAddRoundDialog();
          },
          child: const Text('新しい局を追加'),
        ),
        const SizedBox(height: 16),
        if (_rounds.isEmpty)
          const Text('局を追加してください')
        else
          ..._rounds.asMap().entries.map((entry) {
            final index = entry.key;
            final round = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('第${round.roundNumber}局'),
                subtitle: Text(
                  _selectedPlayers
                      .map((p) =>
                          '${p?.name}: ${round.scores[p?.id] ?? 0}')
                      .join(', '),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _rounds.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildConfirmation() {
    if (_rounds.isEmpty) {
      return const Text('局が記録されていません');
    }

    final Map<String, int> totalScores = {};
    for (var player in _selectedPlayers) {
      if (player != null) {
        totalScores[player.id] = 0;
      }
    }

    for (var round in _rounds) {
      round.scores.forEach((playerId, score) {
        totalScores[playerId] = (totalScores[playerId] ?? 0) + score;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最終結果',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._selectedPlayers.map((player) {
          if (player == null) return const SizedBox.shrink();
          final score = totalScores[player.id] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: Text(player.name)),
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
        const SizedBox(height: 16),
        Text('総局数: ${_rounds.length}局'),
      ],
    );
  }

  void _showAddRoundDialog() {
    final Map<String, TextEditingController> controllers = {};
    for (var player in _selectedPlayers) {
      if (player != null) {
        controllers[player.id] = TextEditingController();
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('第${_rounds.length + 1}局の点数入力'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _selectedPlayers.map((player) {
                if (player == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextField(
                    controller: controllers[player.id],
                    decoration: InputDecoration(
                      labelText: player.name,
                      border: const OutlineInputBorder(),
                      prefixText: '±',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(signed: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final Map<String, int> scores = {};
                int total = 0;

                for (var entry in controllers.entries) {
                  final value = int.tryParse(entry.value.text) ?? 0;
                  scores[entry.key] = value;
                  total += value;
                }

                if (total != 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('点数の合計が0になりません（合計: $total）')),
                  );
                  return;
                }

                final round = Round(
                  id: const Uuid().v4(),
                  roundNumber: _rounds.length + 1,
                  scores: scores,
                  createdAt: DateTime.now(),
                );

                setState(() {
                  _rounds.add(round);
                });

                Navigator.of(context).pop();
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      // プレイヤー選択の検証
      if (_selectedPlayers.any((p) => p == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('全てのプレイヤーを選択してください')),
        );
        return;
      }

      // 重複チェック
      final playerIds = _selectedPlayers.map((p) => p!.id).toSet();
      if (playerIds.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('同じプレイヤーを複数回選択できません')),
        );
        return;
      }

      setState(() {
        _currentStep += 1;
      });
    } else if (_currentStep == 1) {
      // 点数記録の検証
      if (_rounds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('最低1局は記録してください')),
        );
        return;
      }

      setState(() {
        _currentStep += 1;
      });
    } else if (_currentStep == 2) {
      // 対局を保存
      _saveGame();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _saveGame() {
    final game = Game(
      id: const Uuid().v4(),
      date: DateTime.now(),
      playerIds: _selectedPlayers.map((p) => p!.id).toList(),
      rounds: _rounds,
      createdAt: DateTime.now(),
    );

    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.addGame(game);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('対局を記録しました')),
    );

    Navigator.of(context).pop();
  }
}
