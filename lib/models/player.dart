class Player {
  final String id;
  final String name;
  final int gamesPlayed;
  final int gamesWon;

  Player({
    required this.id,
    required this.name,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'games_played': gamesPlayed,
      'games_won': gamesWon,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      gamesPlayed: map['games_played'] as int? ?? 0,
      gamesWon: map['games_won'] as int? ?? 0,
    );
  }

  Player copyWith({
    String? id,
    String? name,
    int? gamesPlayed,
    int? gamesWon,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
    );
  }
}
