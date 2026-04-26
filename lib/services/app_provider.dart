import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/game.dart';
import 'storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<Player> _players = [];
  List<Game> _games = [];
  bool _isLoading = false;

  AppProvider(this._storageService);

  List<Player> get players => _players;
  List<Game> get games => _games;
  bool get isLoading => _isLoading;

  // 初期化
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _storageService.init();
    await loadPlayers();
    await loadGames();

    _isLoading = false;
    notifyListeners();
  }

  // プレイヤー関連

  Future<void> loadPlayers() async {
    _players = await _storageService.getAllPlayers();
    notifyListeners();
  }

  Future<void> addPlayer(Player player) async {
    await _storageService.savePlayer(player);
    await loadPlayers();
  }

  Future<void> updatePlayer(Player player) async {
    await _storageService.savePlayer(player);
    await loadPlayers();
  }

  Future<void> deletePlayer(String id) async {
    await _storageService.deletePlayer(id);
    await loadPlayers();
  }

  Player? getPlayerById(String id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // 対局（Game）関連

  Future<void> loadGames() async {
    _games = await _storageService.getAllGames();
    notifyListeners();
  }

  Future<void> addGame(Game game) async {
    await _storageService.saveGame(game);
    await loadGames();
  }

  Future<void> updateGame(Game game) async {
    await _storageService.saveGame(game);
    await loadGames();
  }

  Future<void> deleteGame(String id) async {
    await _storageService.deleteGame(id);
    await loadGames();
  }

  // 統計情報
  Future<Map<String, dynamic>> getPlayerStats(String playerId) async {
    return await _storageService.getPlayerStats(playerId);
  }
}
