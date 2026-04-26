class Player {
  final String id;
  final String name;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // JSONシリアライズ用
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // JSONデシリアライズ用
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Player copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
