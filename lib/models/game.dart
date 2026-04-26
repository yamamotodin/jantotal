import 'round.dart';

class Game {
  final String id;
  final DateTime date;
  final List<String> playerIds; // 4人分のプレイヤーID
  final List<Round> rounds; // 半荘のリスト
  final DateTime createdAt;

  Game({
    required this.id,
    required this.date,
    required this.playerIds,
    required this.rounds,
    required this.createdAt,
  });

  // 各プレイヤーの合計点数を計算
  Map<String, int> getTotalScores() {
    Map<String, int> totalScores = {};
    for (var playerId in playerIds) {
      totalScores[playerId] = 0;
    }

    for (var round in rounds) {
      round.scores.forEach((playerId, score) {
        totalScores[playerId] = (totalScores[playerId] ?? 0) + score;
      });
    }

    return totalScores;
  }

  // 順位を計算（1位=0, 2位=1, 3位=2, 4位=3）
  Map<String, int> getRankings() {
    final totalScores = getTotalScores();
    final sortedEntries = totalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Map<String, int> rankings = {};
    for (int i = 0; i < sortedEntries.length; i++) {
      rankings[sortedEntries[i].key] = i;
    }

    return rankings;
  }

  // JSONシリアライズ用
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'playerIds': playerIds,
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // JSONデシリアライズ用
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      playerIds: List<String>.from(json['playerIds'] as List),
      rounds: (json['rounds'] as List)
          .map((r) => Round.fromJson(r as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Game copyWith({
    String? id,
    DateTime? date,
    List<String>? playerIds,
    List<Round>? rounds,
    DateTime? createdAt,
  }) {
    return Game(
      id: id ?? this.id,
      date: date ?? this.date,
      playerIds: playerIds ?? this.playerIds,
      rounds: rounds ?? this.rounds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
