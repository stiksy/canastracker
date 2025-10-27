# Canastracker Architecture

This document describes the architecture and design decisions of the Canastracker application.

## Table of Contents
- [Technology Stack](#technology-stack)
- [Architecture Pattern](#architecture-pattern)
- [Project Structure](#project-structure)
- [Data Flow](#data-flow)
- [Database Design](#database-design)
- [State Management](#state-management)
- [Key Components](#key-components)
- [Design Decisions](#design-decisions)

## Technology Stack

### Framework & Language
- **Flutter 3.35.7**: Cross-platform UI framework (targeting Android)
- **Dart 3.9.2**: Programming language
- **Material Design 3**: UI design system

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0           # State management
  sqflite: ^2.3.0            # SQLite database
  path_provider: ^2.1.1      # File system paths
  uuid: ^4.1.0               # Unique ID generation
  intl: ^0.18.1              # Internationalization
```

### Build System
- **Android Gradle Plugin**: 8.7.3
- **Gradle**: 8.11
- **Kotlin**: 1.9.0
- **Target SDK**: Android API 36
- **Minimum SDK**: Android API 21 (Lollipop)

## Architecture Pattern

Canastracker follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│         (Flutter Widgets)           │
│  ┌──────────────────────────────┐  │
│  │  Screens (UI Components)     │  │
│  └──────────────────────────────┘  │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│       State Management Layer        │
│    (Provider Pattern - ChangeNotifier)
│  ┌──────────────────────────────┐  │
│  │  GameProvider                │  │
│  │  HistoryProvider             │  │
│  └──────────────────────────────┘  │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│        Business Logic Layer         │
│  ┌──────────────────────────────┐  │
│  │  ScoringService              │  │
│  │  CanastraRules               │  │
│  └──────────────────────────────┘  │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│        Data Access Layer            │
│  ┌──────────────────────────────┐  │
│  │  DatabaseService (SQLite)    │  │
│  └──────────────────────────────┘  │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│          Data Layer                 │
│  ┌──────────────────────────────┐  │
│  │  Models (Entities)           │  │
│  │  - Player, Team, Game, Round│  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns**: Each layer has a single, well-defined responsibility
2. **Dependency Inversion**: Higher layers depend on abstractions, not concrete implementations
3. **Unidirectional Data Flow**: Data flows from user actions → providers → services → database
4. **Reactive UI**: UI automatically updates when state changes via `ChangeNotifier`

## Project Structure

### Directory Overview

```
lib/
├── main.dart                     # Application entry point & initialization
├── models/                       # Domain entities (PODOs)
├── providers/                    # State management (ChangeNotifier)
├── screens/                      # UI screens (StatefulWidget/StatelessWidget)
├── services/                     # Business logic & data access
└── utils/                        # Constants, helpers, and rules
```

### Layer Responsibilities

#### **Models** (`lib/models/`)
- Pure data classes with no business logic
- `toMap()` / `fromMap()` for serialization
- Immutable where possible (`final` fields)
- `copyWith()` for creating modified copies

**Files:**
- `player.dart`: Player entity with statistics
- `team.dart`: Team entity with list of players
- `game.dart`: Game entity with teams, rounds, and status
- `round.dart`: Round and RoundScore entities

#### **Providers** (`lib/providers/`)
- Extend `ChangeNotifier` for reactive state updates
- Coordinate between UI and services
- Manage app-wide state
- Handle business workflows

**Files:**
- `game_provider.dart`: Manages current game state, player operations, round management
- `history_provider.dart`: Manages game history and statistics

#### **Screens** (`lib/screens/`)
- Stateless/Stateful widgets for UI
- Use `Consumer<Provider>` for reactive updates
- Minimal business logic (delegates to providers)
- Material Design 3 components

**Files:**
- `home_screen.dart`: Main menu with navigation
- `new_game_screen.dart`: Game configuration and team setup
- `game_screen.dart`: Active game display
- `round_entry_screen.dart`: Round score input form
- `history_screen.dart`: Game history list

#### **Services** (`lib/services/`)
- Business logic and algorithms
- Data access operations
- No UI dependencies

**Files:**
- `database_service.dart`: SQLite CRUD operations, schema management
- `scoring_service.dart`: Score calculation, validation, breakdown

#### **Utils** (`lib/utils/`)
- Constants and configuration
- Pure functions
- Game rules and point values

**Files:**
- `canastra_rules.dart`: Scoring constants and rule validation

## Data Flow

### User Action Flow

```
User Input (Screen)
      ↓
UI Event Handler
      ↓
Provider Method Call
      ↓
Business Logic (Service)
      ↓
Database Operation (DatabaseService)
      ↓
Database (SQLite)
      ↓
Provider.notifyListeners()
      ↓
Consumer<Provider> Rebuilds
      ↓
UI Updates
```

### Example: Adding a Round

```dart
// 1. User taps "Salvar Rodada" in RoundEntryScreen
onPressed: _submitRound

// 2. Screen calls provider
await gameProvider.addRound(teamScores);

// 3. Provider processes scores
GameProvider.addRound(Map<String, RoundScore> teamScores) {
  // 4. Calculate scores via service
  final calculatedScore = ScoringService.calculateRoundScore(roundScore);

  // 5. Create round entity
  final round = Round(...);

  // 6. Persist to database
  await _databaseService.insertRound(gameId, round);

  // 7. Reload game state
  _currentGame = await _databaseService.getGame(gameId);

  // 8. Check win condition
  await _checkGameCompletion();

  // 9. Notify UI
  notifyListeners();
}

// 10. Consumer rebuilds GameScreen
Consumer<GameProvider>(
  builder: (context, gameProvider, child) {
    return GameScreen(game: gameProvider.currentGame);
  }
)
```

## Database Design

### Technology
- **SQLite** via `sqflite` package
- **Version**: 5 (with migration support)
- **Location**: Application documents directory

### Schema

#### Players Table
```sql
CREATE TABLE players (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  games_played INTEGER DEFAULT 0,
  games_won INTEGER DEFAULT 0
)
```

#### Games Table
```sql
CREATE TABLE games (
  id TEXT PRIMARY KEY,
  start_time TEXT NOT NULL,
  end_time TEXT,
  status TEXT NOT NULL,
  winner_id TEXT,
  target_score INTEGER DEFAULT 5000,
  number_of_decks INTEGER DEFAULT 2
)
```

#### Teams Table
```sql
CREATE TABLE teams (
  id TEXT PRIMARY KEY,
  game_id TEXT NOT NULL,
  name TEXT NOT NULL,
  score INTEGER DEFAULT 0,
  FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
)
```

#### Team Players Table (Junction)
```sql
CREATE TABLE team_players (
  team_id TEXT NOT NULL,
  player_id TEXT NOT NULL,
  PRIMARY KEY (team_id, player_id),
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
  FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
)
```

#### Rounds Table
```sql
CREATE TABLE rounds (
  id TEXT PRIMARY KEY,
  game_id TEXT NOT NULL,
  round_number INTEGER NOT NULL,
  FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
)
```

#### Round Scores Table
```sql
CREATE TABLE round_scores (
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
  FOREIGN KEY (round_id) REFERENCES rounds(id) ON DELETE CASCADE,
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
)
```

### Entity Relationships

```
Player ──< team_players >── Team ──< Game
                                    │
                                    └─── Round ──< RoundScore
```

### Indexes
- `idx_games_status`: Fast filtering by game status
- `idx_teams_game`: Fast team lookups by game
- `idx_rounds_game`: Fast round lookups by game

### Migrations
Handled via `_onUpgrade()` callback:
- Version 1-3: Initial schema iterations
- Version 4: Added `black_threes` column, fixed column names
- Version 5: Added `number_of_decks` column to games table

## State Management

### Provider Pattern

Canastracker uses the **Provider** package with `ChangeNotifier` pattern:

```dart
class GameProvider with ChangeNotifier {
  // Private state
  Game? _currentGame;
  List<Player> _availablePlayers = [];

  // Public getters
  Game? get currentGame => _currentGame;
  List<Player> get availablePlayers => _availablePlayers;

  // State mutation methods
  Future<void> startNewGame(List<Team> teams) async {
    // ... update state
    notifyListeners(); // Trigger UI rebuild
  }
}
```

### Provider Tree

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

### Consuming State

**Method 1: Consumer Widget** (Preferred for partial rebuilds)
```dart
Consumer<GameProvider>(
  builder: (context, gameProvider, child) {
    return Text('Score: ${gameProvider.currentScore}');
  },
)
```

**Method 2: context.watch** (Rebuilds entire widget)
```dart
final gameProvider = context.watch<GameProvider>();
return Text('Score: ${gameProvider.currentScore}');
```

**Method 3: context.read** (One-time access, no rebuild)
```dart
onPressed: () {
  context.read<GameProvider>().startNewGame(teams);
}
```

### State Lifecycle

1. **Initialization**: Providers initialized in `main()`, call `initialize()` methods
2. **Load State**: `GameProvider.loadInProgressGame()` loads persisted game on startup
3. **User Interaction**: UI calls provider methods to mutate state
4. **Persistence**: Provider saves to database via `DatabaseService`
5. **Notification**: `notifyListeners()` triggers UI rebuild
6. **Disposal**: `dispose()` called when provider is removed from tree

## Key Components

### GameProvider

**Responsibilities:**
- Manage current game state
- Player CRUD operations
- Round submission and validation
- Game completion detection
- Auto-load in-progress games

**Key Methods:**
- `startNewGame(teams, {numberOfDecks})`: Initialize new game
- `loadGame(gameId)`: Load existing game
- `loadInProgressGame()`: Auto-load on startup
- `addRound(teamScores)`: Submit round, check win condition
- `endGame(winnerId)`: Mark game complete, update player stats

### DatabaseService

**Responsibilities:**
- SQLite connection management
- Schema creation and migrations
- CRUD operations for all entities
- Foreign key enforcement

**Key Methods:**
- `database`: Lazy-initialized database getter
- `insertGame(game)`: Insert game with teams
- `getGame(id)`: Load game with teams and rounds
- `insertRound(gameId, round)`: Insert round with scores
- `_onUpgrade(db, oldVersion, newVersion)`: Handle migrations

### ScoringService

**Responsibilities:**
- Calculate round scores
- Validate scoring rules
- Generate score breakdowns

**Key Methods:**
- `calculateRoundScore(roundScore)`: Apply all scoring rules
- `canTeamGoOut(roundScore)`: Validate going out conditions
- `getMinimumMeld(currentScore)`: Get minimum meld requirement
- `getScoreBreakdown(roundScore)`: Itemize point sources

### RoundEntryScreen

**Responsibilities:**
- Collect score inputs for each team
- Display real-time score calculations
- Validate 3s across all teams
- Submit completed round

**Key Features:**
- Single "Qual time bateu?" radio selector
- Per-team score cards with counters
- Live score breakdown (Detalhamento)
- Global 3s validation (can't exceed decks × 4)

## Design Decisions

### Why Provider Over Other State Management?

**Chosen**: Provider pattern with ChangeNotifier

**Alternatives Considered**: Bloc, Riverpod, GetX

**Rationale**:
- Simple learning curve
- Built-in Flutter support
- Sufficient for app complexity
- Clear separation from UI layer

### Why SQLite Over Other Storage?

**Chosen**: SQLite via `sqflite`

**Alternatives Considered**: Shared Preferences, Hive, Cloud Firestore

**Rationale**:
- Relational data (teams, players, games, rounds)
- ACID transactions for data integrity
- Complex queries (joins, aggregations)
- Offline-first requirement
- No backend needed

### Why Immutable Models?

**Chosen**: Models with `final` fields and `copyWith()` methods

**Rationale**:
- Prevents accidental mutations
- Easier to reason about state changes
- Better debugging (clear mutation points)
- Supports time-travel debugging

### Why Single "Bateu" Selector?

**Old Design**: Individual checkbox per team

**New Design**: Single radio selector at top

**Rationale**:
- Only one team can go out per round (game rule)
- Reduces user error (checking multiple teams)
- Clearer UX (explicit "which team" question)
- Simplifies validation logic

### Why Global 3s Validation?

**Design**: Total 3s across ALL teams cannot exceed decks × 4

**Rationale**:
- Physical constraint (limited cards in decks)
- Prevents impossible game states
- Catches data entry errors
- Real-time feedback (+ button disables)

### Why Portuguese UI?

**Rationale**:
- Target audience: Brazilian players
- Game terminology (Canastra, Batida, etc.)
- Cultural context and familiarity
- No English variant of Canastra

### Database Version Strategy

**Approach**: Incremental migrations with `_onUpgrade()`

**Rationale**:
- Preserves user data across updates
- Allows schema evolution
- Clear upgrade path
- Rollback support via version checks

## Performance Considerations

### Database Queries
- **Indexed Columns**: game_id, team_id, status
- **Eager Loading**: Games load with teams and rounds in single transaction
- **Cascade Deletes**: Database handles cleanup, not application

### UI Rendering
- **Consumer Granularity**: Use `Consumer<T>` for specific widgets, not entire screens
- **Const Constructors**: Static widgets use `const` to prevent rebuilds
- **ListView.builder**: Efficient list rendering for history

### State Updates
- **Batched Notifications**: Group state changes, single `notifyListeners()`
- **Debouncing**: Input fields update local state, submit once
- **Lazy Loading**: Database initialized on first access

## Future Improvements

### Architecture
- [ ] Migrate to **Riverpod** for better testability and scope management
- [ ] Add **Repository Pattern** layer between providers and database
- [ ] Implement **Use Cases** for complex business logic

### Features
- [ ] **Undo/Redo**: Round deletion and editing
- [ ] **Cloud Sync**: Firebase backend for multi-device
- [ ] **Offline Queue**: Sync pending changes when online
- [ ] **Export**: CSV/PDF game summaries

### Testing
- [ ] Unit tests for services and providers
- [ ] Widget tests for screens
- [ ] Integration tests for workflows
- [ ] Golden tests for UI consistency

### Performance
- [ ] Pagination for game history
- [ ] Background database operations
- [ ] Image caching (when app icon added)

## References

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Material Design 3](https://m3.material.io/)
- [Canastra Rules](https://en.wikipedia.org/wiki/Canasta)
