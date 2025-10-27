class RoundScore {
  final String teamId;
  final int cleanCanastas;
  final int dirtyCanastas;
  final int redThrees;
  final int blackThrees;
  final int meldPoints;
  final int cardsInHand;
  final bool wentOut;
  final int totalScore;

  RoundScore({
    required this.teamId,
    this.cleanCanastas = 0,
    this.dirtyCanastas = 0,
    this.redThrees = 0,
    this.blackThrees = 0,
    this.meldPoints = 0,
    this.cardsInHand = 0,
    this.wentOut = false,
    required this.totalScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'team_id': teamId,
      'clean_canastas': cleanCanastas,
      'dirty_canastas': dirtyCanastas,
      'red_threes': redThrees,
      'black_threes': blackThrees,
      'meld_points': meldPoints,
      'cards_in_hand': cardsInHand,
      'went_out': wentOut ? 1 : 0,
      'total_score': totalScore,
    };
  }

  factory RoundScore.fromMap(Map<String, dynamic> map) {
    return RoundScore(
      teamId: map['team_id'] as String,
      cleanCanastas: map['clean_canastas'] as int? ?? 0,
      dirtyCanastas: map['dirty_canastas'] as int? ?? 0,
      redThrees: map['red_threes'] as int? ?? 0,
      blackThrees: map['black_threes'] as int? ?? 0,
      meldPoints: map['meld_points'] as int? ?? 0,
      cardsInHand: map['cards_in_hand'] as int? ?? 0,
      wentOut: (map['went_out'] as int? ?? 0) == 1,
      totalScore: map['total_score'] as int,
    );
  }
}

class Round {
  final String id;
  final int roundNumber;
  final Map<String, RoundScore> teamScores;

  Round({
    required this.id,
    required this.roundNumber,
    required this.teamScores,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'round_number': roundNumber,
    };
  }

  factory Round.fromMap(Map<String, dynamic> map) {
    return Round(
      id: map['id'] as String,
      roundNumber: map['round_number'] as int,
      teamScores: {},
    );
  }
}
