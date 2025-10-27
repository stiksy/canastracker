import 'team.dart';
import 'round.dart';

enum GameStatus { inProgress, completed }

class Game {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<Team> teams;
  final List<Round> rounds;
  final GameStatus status;
  final String? winnerId;
  final int targetScore;
  final int numberOfDecks;

  Game({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.teams,
    this.rounds = const [],
    this.status = GameStatus.inProgress,
    this.winnerId,
    this.targetScore = 5000,
    this.numberOfDecks = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status == GameStatus.completed ? 'completed' : 'in_progress',
      'winner_id': winnerId,
      'target_score': targetScore,
      'number_of_decks': numberOfDecks,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map, List<Team> teams, List<Round> rounds) {
    return Game(
      id: map['id'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      teams: teams,
      rounds: rounds,
      status: map['status'] == 'completed' ? GameStatus.completed : GameStatus.inProgress,
      winnerId: map['winner_id'] as String?,
      targetScore: map['target_score'] as int? ?? 5000,
      numberOfDecks: map['number_of_decks'] as int? ?? 2,
    );
  }

  Game copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<Team>? teams,
    List<Round>? rounds,
    GameStatus? status,
    String? winnerId,
    int? targetScore,
    int? numberOfDecks,
  }) {
    return Game(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      teams: teams ?? this.teams,
      rounds: rounds ?? this.rounds,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      targetScore: targetScore ?? this.targetScore,
      numberOfDecks: numberOfDecks ?? this.numberOfDecks,
    );
  }

  Map<String, int> getCurrentScores() {
    final scores = <String, int>{};
    for (final team in teams) {
      scores[team.id] = 0;
    }

    for (final round in rounds) {
      for (final entry in round.teamScores.entries) {
        scores[entry.key] = (scores[entry.key] ?? 0) + entry.value.totalScore;
      }
    }

    return scores;
  }

  Team? getWinner() {
    if (winnerId != null) {
      return teams.firstWhere((t) => t.id == winnerId);
    }
    return null;
  }
}
