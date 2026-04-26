import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/app_provider.dart';
import '../models/player.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイヤー管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.players.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('プレイヤーが登録されていません',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  const Text('下のボタンからプレイヤーを追加してください',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.players.length,
            itemBuilder: (context, index) {
              final player = provider.players[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(player.name[0]),
                  ),
                  title: Text(player.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showPlayerDialog(context, player: player);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteDialog(context, player);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPlayerDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPlayerDialog(BuildContext context, {Player? player}) {
    final isEditing = player != null;
    final nameController = TextEditingController(text: player?.name ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'プレイヤー編集' : 'プレイヤー追加'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'プレイヤー名',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
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
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  return;
                }

                final provider = Provider.of<AppProvider>(context, listen: false);

                if (isEditing) {
                  final updatedPlayer = player.copyWith(name: name);
                  provider.updatePlayer(updatedPlayer);
                } else {
                  final newPlayer = Player(
                    id: const Uuid().v4(),
                    name: name,
                    createdAt: DateTime.now(),
                  );
                  provider.addPlayer(newPlayer);
                }

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? '更新' : '追加'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Player player) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('プレイヤー削除'),
          content: Text('「${player.name}」を削除しますか？'),
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
                provider.deletePlayer(player.id);
                Navigator.of(context).pop();
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
