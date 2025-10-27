import '../models/round.dart';
import '../utils/canastra_rules.dart';

class ScoringService {
  /// Calculate the total score for a team in a specific round
  static int calculateRoundScore(RoundScore roundScore) {
    return CanastraRules.calculateRoundScore(
      cleanCanastas: roundScore.cleanCanastas,
      dirtyCanastas: roundScore.dirtyCanastas,
      redThrees: roundScore.redThrees,
      blackThrees: roundScore.blackThrees,
      meldPoints: roundScore.meldPoints,
      cardsInHand: roundScore.cardsInHand,
      wentOut: roundScore.wentOut,
    );
  }

  /// Validate if a team can go out
  static bool canTeamGoOut(RoundScore roundScore) {
    final totalCanastas = roundScore.cleanCanastas + roundScore.dirtyCanastas;

    return CanastraRules.canGoOut(
      totalCanastas: totalCanastas,
      cleanCanastas: roundScore.cleanCanastas,
    );
  }

  /// Get the minimum meld requirement based on current score
  static int getMinimumMeld(int currentScore) {
    return CanastraRules.getMinimumMeldRequirement(currentScore);
  }

  /// Validate if the meld meets the minimum requirement
  static bool validateMinimumMeld({
    required int meldPoints,
    required int currentScore,
  }) {
    return CanastraRules.meetsMinimumMeld(
      meldPoints: meldPoints,
      currentScore: currentScore,
    );
  }

  /// Get a breakdown of the score components
  static Map<String, int> getScoreBreakdown(RoundScore roundScore) {
    final breakdown = <String, int>{};

    // Canastas
    if (roundScore.cleanCanastas > 0) {
      breakdown['Canastra Limpa'] =
          roundScore.cleanCanastas * CanastraRules.cleanCanastaBonus;
    }
    if (roundScore.dirtyCanastas > 0) {
      breakdown['Canastra Suja'] =
          roundScore.dirtyCanastas * CanastraRules.dirtyCanastaBonus;
    }

    // Red 3s
    if (roundScore.redThrees > 0) {
      breakdown['3 Vermelhos'] = roundScore.redThrees * CanastraRules.redThreeBonus;
    }

    // Black 3s
    if (roundScore.blackThrees > 0) {
      breakdown['3 Pretos'] = roundScore.blackThrees * CanastraRules.blackThreePenalty;
    }

    // Melds
    if (roundScore.meldPoints > 0) {
      breakdown['Pontos de Jogo'] = roundScore.meldPoints;
    }

    // Cards in hand (negative)
    if (roundScore.cardsInHand > 0) {
      breakdown['Cartas na Mão'] = -roundScore.cardsInHand;
    }

    // Going out bonus
    if (roundScore.wentOut) {
      breakdown['Batida'] = CanastraRules.goingOutBonus;
    }

    return breakdown;
  }
}
