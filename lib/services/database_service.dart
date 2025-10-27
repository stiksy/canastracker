import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../models/round.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'canastracker.db';
  static const int _databaseVersion = 5;

  // Table names
  static const String _playersTable = 'players';
  static const String _gamesTable = 'games';
  static const String _teamsTable = 'teams';
  static const String _teamPlayersTable = 'team_players';
  static const String _roundsTable = 'rounds';
  static const String _roundScoresTable = 'round_scores';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // For simplicity, drop and recreate the round_scores table with correct schema
      // This is acceptable during development as game data can be replayed
      await db.execute('DROP TABLE IF EXISTS $_roundScoresTable');

      // Recreate with correct schema
      await db.execute('''
        CREATE TABLE $_roundScoresTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          round_id TEXT NOT NULL,
          team_id TEXT NOT NULL,
          clean_canastas INTEGER DEFAULT 0,
          dirty_canastas INTEGER DEFAULT 0,
          red_threes INTEGER DEFAULT 0,
          black_threes INTEGER DEFAULT 0,
          meld_points INTEGER DEFAULT 0,
          cards_in_hand INTEGER DEFAULT 0,
          went_out INTEGER DEFAULT 0,
          total_score INTEGER NOT NULL,
          FOREIGN KEY (round_id) REFERENCES $_roundsTable (id) ON DELETE CASCADE,
          FOREIGN KEY (team_id) REFERENCES $_teamsTable (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 5) {
      // Add number_of_decks column to games table
      await db.execute('ALTER TABLE $_gamesTable ADD COLUMN number_of_decks INTEGER DEFAULT 2');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Players table
    await db.execute('''
      CREATE TABLE $_playersTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        games_played INTEGER DEFAULT 0,
        games_won INTEGER DEFAULT 0
      )
    ''');

    // Games table
    await db.execute('''
      CREATE TABLE $_gamesTable (
        id TEXT PRIMARY KEY,
        start_time TEXT NOT NULL,
        end_time TEXT,
        status TEXT NOT NULL,
        winner_id TEXT,
        target_score INTEGER DEFAULT 5000,
        number_of_decks INTEGER DEFAULT 2
      )
    ''');

    // Teams table
    await db.execute('''
      CREATE TABLE $_teamsTable (
        id TEXT PRIMARY KEY,
        game_id TEXT NOT NULL,
        name TEXT NOT NULL,
        score INTEGER DEFAULT 0,
        FOREIGN KEY (game_id) REFERENCES $_gamesTable (id) ON DELETE CASCADE
      )
    ''');

    // Team-Players junction table
    await db.execute('''
      CREATE TABLE $_teamPlayersTable (
        team_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        PRIMARY KEY (team_id, player_id),
        FOREIGN KEY (team_id) REFERENCES $_teamsTable (id) ON DELETE CASCADE,
        FOREIGN KEY (player_id) REFERENCES $_playersTable (id) ON DELETE CASCADE
      )
    ''');

    // Rounds table
    await db.execute('''
      CREATE TABLE $_roundsTable (
        id TEXT PRIMARY KEY,
        game_id TEXT NOT NULL,
        round_number INTEGER NOT NULL,
        FOREIGN KEY (game_id) REFERENCES $_gamesTable (id) ON DELETE CASCADE
      )
    ''');

    // Round scores table
    await db.execute('''
      CREATE TABLE $_roundScoresTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        round_id TEXT NOT NULL,
        team_id TEXT NOT NULL,
        clean_canastas INTEGER DEFAULT 0,
        dirty_canastas INTEGER DEFAULT 0,
        red_threes INTEGER DEFAULT 0,
        black_threes INTEGER DEFAULT 0,
        meld_points INTEGER DEFAULT 0,
        cards_in_hand INTEGER DEFAULT 0,
        went_out INTEGER DEFAULT 0,
        total_score INTEGER NOT NULL,
        FOREIGN KEY (round_id) REFERENCES $_roundsTable (id) ON DELETE CASCADE,
        FOREIGN KEY (team_id) REFERENCES $_teamsTable (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_games_status ON $_gamesTable(status)');
    await db.execute('CREATE INDEX idx_teams_game ON $_teamsTable(game_id)');
    await db.execute('CREATE INDEX idx_rounds_game ON $_roundsTable(game_id)');
  }

  // Player operations
  Future<String> insertPlayer(Player player) async {
    final db = await database;
    await db.insert(_playersTable, player.toMap());
    return player.id;
  }

  Future<Player?> getPlayer(String id) async {
    final db = await database;
    final maps = await db.query(
      _playersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Player.fromMap(maps.first);
  }

  Future<List<Player>> getAllPlayers() async {
    final db = await database;
    final maps = await db.query(_playersTable, orderBy: 'name ASC');
    return maps.map((map) => Player.fromMap(map)).toList();
  }

  Future<void> updatePlayer(Player player) async {
    final db = await database;
    await db.update(
      _playersTable,
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<void> deletePlayer(String id) async {
    final db = await database;
    await db.delete(_playersTable, where: 'id = ?', whereArgs: [id]);
  }

  // Game operations
  Future<String> insertGame(Game game) async {
    final db = await database;
    await db.insert(_gamesTable, game.toMap());

    // Insert teams
    for (final team in game.teams) {
      await db.insert(_teamsTable, {
        ...team.toMap(),
        'game_id': game.id,
      });

      // Insert team players
      for (final player in team.players) {
        await db.insert(_teamPlayersTable, {
          'team_id': team.id,
          'player_id': player.id,
        });
      }
    }

    return game.id;
  }

  Future<Game?> getGame(String id) async {
    final db = await database;
    final gameMaps = await db.query(_gamesTable, where: 'id = ?', whereArgs: [id]);
    if (gameMaps.isEmpty) return null;

    // Get teams
    final teams = await _getGameTeams(db, id);

    // Get rounds
    final rounds = await _getGameRounds(db, id);

    return Game.fromMap(gameMaps.first, teams, rounds);
  }

  Future<List<Game>> getAllGames() async {
    final db = await database;
    final gameMaps = await db.query(_gamesTable, orderBy: 'start_time DESC');

    final games = <Game>[];
    for (final gameMap in gameMaps) {
      final gameId = gameMap['id'] as String;
      final teams = await _getGameTeams(db, gameId);
      final rounds = await _getGameRounds(db, gameId);
      games.add(Game.fromMap(gameMap, teams, rounds));
    }

    return games;
  }

  Future<List<Team>> _getGameTeams(Database db, String gameId) async {
    final teamMaps = await db.query(
      _teamsTable,
      where: 'game_id = ?',
      whereArgs: [gameId],
    );

    final teams = <Team>[];
    for (final teamMap in teamMaps) {
      final teamId = teamMap['id'] as String;

      // Get team players
      final playerIds = await db.query(
        _teamPlayersTable,
        columns: ['player_id'],
        where: 'team_id = ?',
        whereArgs: [teamId],
      );

      final players = <Player>[];
      for (final pidMap in playerIds) {
        final player = await getPlayer(pidMap['player_id'] as String);
        if (player != null) players.add(player);
      }

      teams.add(Team.fromMap(teamMap, players));
    }

    return teams;
  }

  Future<List<Round>> _getGameRounds(Database db, String gameId) async {
    final roundMaps = await db.query(
      _roundsTable,
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'round_number ASC',
    );

    final rounds = <Round>[];
    for (final roundMap in roundMaps) {
      final roundId = roundMap['id'] as String;

      // Get round scores
      final scoreMaps = await db.query(
        _roundScoresTable,
        where: 'round_id = ?',
        whereArgs: [roundId],
      );

      final teamScores = <String, RoundScore>{};
      for (final scoreMap in scoreMaps) {
        final score = RoundScore.fromMap(scoreMap);
        teamScores[score.teamId] = score;
      }

      final round = Round.fromMap(roundMap);
      rounds.add(Round(
        id: round.id,
        roundNumber: round.roundNumber,
        teamScores: teamScores,
      ));
    }

    return rounds;
  }

  Future<void> updateGame(Game game) async {
    final db = await database;
    await db.update(
      _gamesTable,
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<void> deleteGame(String id) async {
    final db = await database;
    await db.delete(_gamesTable, where: 'id = ?', whereArgs: [id]);
  }

  // Round operations
  Future<void> insertRound(String gameId, Round round) async {
    final db = await database;

    await db.insert(_roundsTable, {
      ...round.toMap(),
      'game_id': gameId,
    });

    // Insert round scores
    for (final entry in round.teamScores.entries) {
      await db.insert(_roundScoresTable, {
        ...entry.value.toMap(),
        'round_id': round.id,
      });
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
