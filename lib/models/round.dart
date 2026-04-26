class Round {
  final String id;
  final int roundNumber; // 何局目か
  final Map<String, int> scores; // プレイヤーIDと点数のマップ
  final String? notes; // メモ（任意）
  final DateTime createdAt;

  Round({
    required this.id,
    required this.roundNumber,
    required this.scores,
    this.notes,
    required this.createdAt,
  });

  // JSONシリアライズ用
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roundNumber': roundNumber,
      'scores': scores,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // JSONデシリアライズ用
  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      id: json['id'] as String,
      roundNumber: json['roundNumber'] as int,
      scores: Map<String, int>.from(json['scores'] as Map),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Round copyWith({
    String? id,
    int? roundNumber,
    Map<String, int>? scores,
    String? notes,
    DateTime? createdAt,
  }) {
    return Round(
      id: id ?? this.id,
      roundNumber: roundNumber ?? this.roundNumber,
      scores: scores ?? this.scores,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
