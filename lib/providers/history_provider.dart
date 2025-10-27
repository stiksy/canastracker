import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../services/database_service.dart';

class HistoryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Game> _games = [];
  bool _isLoading = false;

  List<Game> get games => _games;
  bool get isLoading => _isLoading;

  List<Game> get completedGames =>
      _games.where((g) => g.status == GameStatus.completed).toList();

  List<Game> get inProgressGames =>
      _games.where((g) => g.status == GameStatus.inProgress).toList();

  // Load all games
  Future<void> loadGames() async {
    _isLoading = true;
    notifyListeners();

    _games = await _databaseService.getAllGames();

    _isLoading = false;
    notifyListeners();
  }

  // Get a specific game
  Future<Game?> getGame(String gameId) async {
    return await _databaseService.getGame(gameId);
  }

  // Delete a game
  Future<void> deleteGame(String gameId) async {
    await _databaseService.deleteGame(gameId);
    await loadGames();
  }

  // Get games filtered by player
  List<Game> getGamesByPlayer(String playerId) {
    return _games.where((game) {
      return game.teams.any((team) {
        return team.players.any((player) => player.id == playerId);
      });
    }).toList();
  }

  // Get player statistics
  Map<String, dynamic> getPlayerStats(String playerId) {
    final playerGames = getGamesByPlayer(playerId);
    final completedPlayerGames = playerGames
        .where((g) => g.status == GameStatus.completed)
        .toList();

    int wins = 0;
    int totalScore = 0;
    int highestScore = 0;

    for (final game in completedPlayerGames) {
      final winner = game.getWinner();
      if (winner != null && winner.players.any((p) => p.id == playerId)) {
        wins++;
      }

      // Calculate player's team score
      for (final team in game.teams) {
        if (team.players.any((p) => p.id == playerId)) {
          final scores = game.getCurrentScores();
          final teamScore = scores[team.id] ?? 0;
          totalScore += teamScore;
          if (teamScore > highestScore) {
            highestScore = teamScore;
          }
        }
      }
    }

    return {
      'gamesPlayed': completedPlayerGames.length,
      'gamesWon': wins,
      'winRate': completedPlayerGames.isEmpty
          ? 0.0
          : (wins / completedPlayerGames.length),
      'averageScore': completedPlayerGames.isEmpty
          ? 0
          : (totalScore / completedPlayerGames.length).round(),
      'highestScore': highestScore,
    };
  }
}
