/// Canastra (Brazilian card game) scoring rules and constants
class CanastraRules {
  // Canasta bonuses
  static const int cleanCanastaBonus = 200; // Clean canasta (no wild cards)
  static const int dirtyCanastaBonus = 100; // Dirty canasta (with wild cards)

  // Red 3s scoring
  static const int redThreeBonus = 100; // Per red 3

  // Black 3s penalty
  static const int blackThreePenalty = -100; // Per black 3

  // Going out bonus
  static const int goingOutBonus = 100;

  // Card point values
  static const Map<String, int> cardValues = {
    'Joker': 20,
    'Ace': 15,
    'King': 10,
    'Queen': 10,
    'Jack': 10,
    '10': 10,
    '9': 10,
    '8': 10,
    '7': 5,
    '6': 5,
    '5': 5,
    '4': 5,
    '2': 10, // Wild card
  };

  // Minimum meld requirements by current score
  static int getMinimumMeldRequirement(int currentScore) {
    if (currentScore < 1500) return 45;
    if (currentScore < 3000) return 75;
    return 90;
  }

  // Calculate total score for a round
  static int calculateRoundScore({
    required int cleanCanastas,
    required int dirtyCanastas,
    required int redThrees,
    required int blackThrees,
    required int meldPoints,
    required int cardsInHand,
    required bool wentOut,
  }) {
    int score = 0;

    // Canasta bonuses
    score += cleanCanastas * cleanCanastaBonus;
    score += dirtyCanastas * dirtyCanastaBonus;

    // Red 3s - always bonus
    score += redThrees * redThreeBonus;

    // Black 3s - always penalty
    score += blackThrees * blackThreePenalty;

    // Meld points (cards laid down)
    score += meldPoints;

    // Cards in hand (subtracted from score)
    score -= cardsInHand;

    // Going out bonus
    if (wentOut) {
      score += goingOutBonus;
    }

    return score;
  }

  // Validate if team can go out
  static bool canGoOut({
    required int totalCanastas,
    required int cleanCanastas,
  }) {
    // Team needs at least 2 canastas, one must be clean
    return totalCanastas >= 2 && cleanCanastas >= 1;
  }

  // Game winning conditions
  static const int defaultTargetScore = 3000;

  // Validate meld minimum
  static bool meetsMinimumMeld({
    required int meldPoints,
    required int currentScore,
  }) {
    final minimumRequired = getMinimumMeldRequirement(currentScore);
    return meldPoints >= minimumRequired;
  }
}
