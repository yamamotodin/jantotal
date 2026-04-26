import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/game.dart';

class StorageService {
  static const String _playersBoxName = 'players';
  static const String _gamesBoxName = 'games';

  late Box<String> _playersBox;
  late Box<String> _gamesBox;

  // 初期化
  Future<void> init() async {
    await Hive.initFlutter();
    _playersBox = await Hive.openBox<String>(_playersBoxName);
    _gamesBox = await Hive.openBox<String>(_gamesBoxName);
  }

  // プレイヤー関連

  Future<List<Player>> getAllPlayers() async {
    final List<Player> players = [];
    for (var key in _playersBox.keys) {
      final jsonString = _playersBox.get(key);
      if (jsonString != null) {
        players.add(Player.fromJson(json.decode(jsonString)));
      }
    }
    // 作成日時順にソート
    players.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return players;
  }

  Future<Player?> getPlayer(String id) async {
    final jsonString = _playersBox.get(id);
    if (jsonString != null) {
      return Player.fromJson(json.decode(jsonString));
    }
    return null;
  }

  Future<void> savePlayer(Player player) async {
    await _playersBox.put(player.id, json.encode(player.toJson()));
  }

  Future<void> deletePlayer(String id) async {
    await _playersBox.delete(id);
  }

  // 対局（Game）関連

  Future<List<Game>> getAllGames() async {
    final List<Game> games = [];
    for (var key in _gamesBox.keys) {
      final jsonString = _gamesBox.get(key);
      if (jsonString != null) {
        games.add(Game.fromJson(json.decode(jsonString)));
      }
    }
    // 日付の新しい順にソート
    games.sort((a, b) => b.date.compareTo(a.date));
    return games;
  }

  Future<Game?> getGame(String id) async {
    final jsonString = _gamesBox.get(id);
    if (jsonString != null) {
      return Game.fromJson(json.decode(jsonString));
    }
    return null;
  }

  Future<void> saveGame(Game game) async {
    await _gamesBox.put(game.id, json.encode(game.toJson()));
  }

  Future<void> deleteGame(String id) async {
    await _gamesBox.delete(id);
  }

  // プレイヤーの統計情報を取得
  Future<Map<String, dynamic>> getPlayerStats(String playerId) async {
    final games = await getAllGames();
    final playerGames = games.where(
      (game) => game.playerIds.contains(playerId),
    ).toList();

    if (playerGames.isEmpty) {
      return {
        'totalGames': 0,
        'totalScore': 0,
        'averageScore': 0.0,
        'rankings': [0, 0, 0, 0], // 1位、2位、3位、4位の回数
        'averageRank': 0.0,
      };
    }

    int totalScore = 0;
    List<int> rankings = [0, 0, 0, 0];

    for (var game in playerGames) {
      final scores = game.getTotalScores();
      final gameRankings = game.getRankings();

      totalScore += scores[playerId] ?? 0;
      final rank = gameRankings[playerId] ?? 0;
      rankings[rank]++;
    }

    final averageScore = totalScore / playerGames.length;
    final averageRank = (rankings[0] * 1 + rankings[1] * 2 +
                         rankings[2] * 3 + rankings[3] * 4) / playerGames.length;

    return {
      'totalGames': playerGames.length,
      'totalScore': totalScore,
      'averageScore': averageScore,
      'rankings': rankings,
      'averageRank': averageRank,
    };
  }
}
