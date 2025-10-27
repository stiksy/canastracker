import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/team.dart';
import '../models/round.dart';
import '../models/player.dart';
import '../services/database_service.dart';
import '../services/scoring_service.dart';

class GameProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  Game? _currentGame;
  List<Player> _availablePlayers = [];

  Game? get currentGame => _currentGame;
  List<Player> get availablePlayers => _availablePlayers;

  // Initialize provider
  Future<void> initialize() async {
    await loadPlayers();
    await loadInProgressGame();
  }

  // Load in-progress game if exists
  Future<void> loadInProgressGame() async {
    final allGames = await _databaseService.getAllGames();
    final inProgressGame = allGames.where((game) => game.status == GameStatus.inProgress).firstOrNull;

    if (inProgressGame != null) {
      _currentGame = inProgressGame;
      notifyListeners();
    }
  }

  // Player management
  Future<void> loadPlayers() async {
    _availablePlayers = await _databaseService.getAllPlayers();
    notifyListeners();
  }

  Future<Player> createPlayer(String name) async {
    final player = Player(
      id: _uuid.v4(),
      name: name,
    );
    await _databaseService.insertPlayer(player);
    await loadPlayers();
    return player;
  }

  Future<void> updatePlayer(Player player) async {
    await _databaseService.updatePlayer(player);
    await loadPlayers();
  }

  Future<void> deletePlayer(String id) async {
    await _databaseService.deletePlayer(id);
    await loadPlayers();
  }

  // Game management
  Future<void> startNewGame(List<Team> teams, {int targetScore = 3000, int numberOfDecks = 2}) async {
    final game = Game(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      teams: teams,
      targetScore: targetScore,
      numberOfDecks: numberOfDecks,
    );

    await _databaseService.insertGame(game);
    _currentGame = game;
    notifyListeners();
  }

  Future<void> loadGame(String gameId) async {
    _currentGame = await _databaseService.getGame(gameId);
    notifyListeners();
  }

  void clearCurrentGame() {
    _currentGame = null;
    notifyListeners();
  }

  // Round management
  Future<void> addRound(Map<String, RoundScore> teamScores) async {
    if (_currentGame == null) return;

    // Calculate scores using the scoring service
    final processedScores = <String, RoundScore>{};
    for (final entry in teamScores.entries) {
      final calculatedScore = ScoringService.calculateRoundScore(entry.value);
      processedScores[entry.key] = RoundScore(
        teamId: entry.value.teamId,
        cleanCanastas: entry.value.cleanCanastas,
        dirtyCanastas: entry.value.dirtyCanastas,
        redThrees: entry.value.redThrees,
        blackThrees: entry.value.blackThrees,
        meldPoints: entry.value.meldPoints,
        cardsInHand: entry.value.cardsInHand,
        wentOut: entry.value.wentOut,
        totalScore: calculatedScore,
      );
    }

    final round = Round(
      id: _uuid.v4(),
      roundNumber: _currentGame!.rounds.length + 1,
      teamScores: processedScores,
    );

    await _databaseService.insertRound(_currentGame!.id, round);

    // Reload game to get updated rounds
    _currentGame = await _databaseService.getGame(_currentGame!.id);

    // Check if game should end
    await _checkGameCompletion();

    notifyListeners();
  }

  Future<void> _checkGameCompletion() async {
    if (_currentGame == null) return;

    final scores = _currentGame!.getCurrentScores();
    String? winnerId;

    for (final entry in scores.entries) {
      if (entry.value >= _currentGame!.targetScore) {
        winnerId = entry.key;
        break;
      }
    }

    if (winnerId != null) {
      await endGame(winnerId);
    }
  }

  Future<void> endGame(String winnerId) async {
    if (_currentGame == null) return;

    final updatedGame = _currentGame!.copyWith(
      status: GameStatus.completed,
      endTime: DateTime.now(),
      winnerId: winnerId,
    );

    await _databaseService.updateGame(updatedGame);

    // Update player statistics
    final winningTeam = updatedGame.teams.firstWhere((t) => t.id == winnerId);
    for (final player in winningTeam.players) {
      final updatedPlayer = player.copyWith(
        gamesPlayed: player.gamesPlayed + 1,
        gamesWon: player.gamesWon + 1,
      );
      await _databaseService.updatePlayer(updatedPlayer);
    }

    // Update losing teams' players
    for (final team in updatedGame.teams) {
      if (team.id != winnerId) {
        for (final player in team.players) {
          final updatedPlayer = player.copyWith(
            gamesPlayed: player.gamesPlayed + 1,
          );
          await _databaseService.updatePlayer(updatedPlayer);
        }
      }
    }

    await loadPlayers();
    _currentGame = updatedGame;
    notifyListeners();
  }

  // Get current scores
  Map<String, int> getCurrentScores() {
    return _currentGame?.getCurrentScores() ?? {};
  }

  // Get minimum meld requirement for a team
  int getMinimumMeldForTeam(String teamId) {
    final currentScore = getCurrentScores()[teamId] ?? 0;
    return ScoringService.getMinimumMeld(currentScore);
  }

  // Validate if team can go out
  bool canTeamGoOut(RoundScore roundScore) {
    return ScoringService.canTeamGoOut(roundScore);
  }

  // Clear current game if it matches the given ID (used when game is deleted)
  void clearGameIfMatches(String gameId) {
    if (_currentGame?.id == gameId) {
      _currentGame = null;
      notifyListeners();
    }
  }
}
