import 'player.dart';

class Team {
  final String id;
  final String name;
  final List<Player> players;
  final int score;

  Team({
    required this.id,
    required this.name,
    required this.players,
    this.score = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'score': score,
    };
  }

  factory Team.fromMap(Map<String, dynamic> map, List<Player> players) {
    return Team(
      id: map['id'] as String,
      name: map['name'] as String,
      players: players,
      score: map['score'] as int? ?? 0,
    );
  }

  Team copyWith({
    String? id,
    String? name,
    List<Player>? players,
    int? score,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
      score: score ?? this.score,
    );
  }

  String get playersNames => players.map((p) => p.name).join(' & ');
}
