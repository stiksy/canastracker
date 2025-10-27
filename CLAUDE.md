# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Canastracker** is a Flutter Android application for tracking scores in Canastra, the Brazilian card game. The app manages players, teams, games, and provides round-by-round score tracking with automatic calculation based on standard Canastra rules.

## Development Setup

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio (for Android development)

### Installation
```bash
# Install dependencies
flutter pub get

# Check Flutter setup
flutter doctor
```

### Development Commands

```bash
# Run the app in development mode
flutter run

# Run with hot reload (default)
flutter run --hot

# Build release APK for Android
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle

# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Format all Dart files
flutter format lib/

# Clean build artifacts
flutter clean
```

### Running on a Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on Android emulator
flutter run
```

## Project Architecture

### Technology Stack
- **Framework**: Flutter 3.35.7
- **Language**: Dart 3.9.2
- **State Management**: Provider pattern
- **Database**: SQLite (via sqflite package)
- **Navigation**: Standard Flutter Navigator
- **UI**: Material Design 3

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── player.dart          # Player entity
│   ├── team.dart            # Team with players
│   ├── game.dart            # Game with teams and rounds
│   └── round.dart           # Round and RoundScore
├── providers/               # State management
│   ├── game_provider.dart   # Current game state
│   └── history_provider.dart # Game history state
├── screens/                 # UI screens
│   ├── home_screen.dart     # Main menu
│   ├── new_game_screen.dart # Game setup
│   ├── game_screen.dart     # Active game view
│   ├── round_entry_screen.dart # Score input
│   └── history_screen.dart  # Past games
├── services/                # Business logic
│   ├── database_service.dart # SQLite operations
│   └── scoring_service.dart  # Score calculations
└── utils/                   # Constants and helpers
    └── canastra_rules.dart  # Game rules and constants
```

### Key Architecture Patterns

**State Management (Provider Pattern)**
- `GameProvider`: Manages current game, players, and rounds
- `HistoryProvider`: Manages game history and statistics
- Both providers use `ChangeNotifier` for reactive updates

**Database Layer**
- `DatabaseService`: Handles all SQLite operations
- Tables: players, games, teams, team_players, rounds, round_scores
- Foreign key relationships for data integrity
- Cascade deletes for cleanup

**Data Flow**
1. User input → Screen
2. Screen → Provider (validates and processes)
3. Provider → Database Service (persists)
4. Provider notifies listeners → UI updates

## Canastra Scoring Rules (Brazilian Variant)

Located in `lib/utils/canastra_rules.dart`:

### Point Values
- Joker: 20 points
- Ace: 15 points
- K, Q, J, 10, 9, 8: 10 points each
- 7, 6, 5, 4: 5 points each
- 2 (wild card): 10 points

### Canasta Bonuses
- **Clean Canasta** (Canastra Limpa - no wild cards): **200 points**
- **Dirty Canasta** (Canastra Suja - with wild cards): **100 points**

### Red 3s (3 Vermelhos)
- Each Red 3: **Always +100 points** (no penalty)
- No special bonus for collecting all 4

### Black 3s (3 Pretos)
- Each Black 3: **-100 points** (penalty)

### Other Rules
- Going out bonus (Batida): **100 points**
- Minimum meld requirements (Abertura mínima) vary by current score:
  - 0-1499: 45 points
  - 1500-2999: 75 points
  - 3000+: 90 points
- To go out: Need at least 2 canastas, one must be clean
- **Target score: 3000 points** (fixed)
- **Number of decks: Configurable (1-4, default 2)**
- **3s Validation**: Total red/black 3s across all teams cannot exceed number_of_decks × 4

## Common Development Workflows

### Adding a New Screen
1. Create screen file in `lib/screens/`
2. Import necessary providers
3. Use `Consumer<Provider>` for reactive updates
4. Add navigation from existing screens

### Modifying Score Calculation
1. Update rules in `lib/utils/canastra_rules.dart`
2. Modify `ScoringService` in `lib/services/scoring_service.dart`
3. Update `RoundScore` model if new fields needed
4. Update database schema in `DatabaseService._onCreate()` if persisting new fields
5. Test with `flutter analyze` and manual testing

### Adding a New Database Field
1. Update model class (e.g., `Player`, `Team`)
2. Add field to `toMap()` and `fromMap()` methods
3. Modify database schema in `DatabaseService._onCreate()`
4. Increment `_databaseVersion` constant
5. Consider adding migration logic for existing users

### Debugging Tips
- Use `flutter run --verbose` for detailed logs
- Check SQLite database: Use Android Device File Explorer in Android Studio
- Provider updates: Add `print()` statements in `notifyListeners()` calls
- UI not updating: Ensure using `Consumer<Provider>` or `context.watch<Provider>()`

## Testing

Currently no automated tests. To add tests:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/scoring_service_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure (when implemented)
```
test/
├── models/          # Model tests
├── services/        # Service layer tests
├── providers/       # Provider state tests
└── widgets/         # Widget tests
```

## Important Implementation Notes

1. **Database Initialization**: Database is initialized lazily on first access via `DatabaseService.database` getter. Current version: 5

2. **Score Calculation**: Always done in `ScoringService.calculateRoundScore()` - never calculate manually in UI

3. **Game State**: Only one game can be "in progress" at a time. Stored in `GameProvider.currentGame`. On app start, `loadInProgressGame()` automatically loads any in-progress game.

4. **Player Management**: Players are global entities that can be reused across multiple games. Multi-select enabled when adding players to teams.

5. **Round Submission**: Rounds are immutable once saved. No edit functionality currently implemented

6. **Navigation**: Uses standard Flutter Navigator with MaterialPageRoute. Consider migrating to go_router for better routing

7. **UI Language**: Entire app is in Portuguese (Brazil)

8. **"Bateu" Logic**: Single radio button selection at top of round entry asking "Qual time bateu?" instead of individual checkboxes per team

9. **Deck Count Validation**: Red/black 3s are validated across all teams - cannot exceed (number_of_decks × 4) total. + buttons disable when max is reached globally.

10. **Database Migrations**: Handled via `_onUpgrade()` in DatabaseService. Always increment `_databaseVersion` when changing schema.

## Recent Features & Changes

### Deck Count Configuration (v1.1)
- **Feature**: Configurable number of decks when starting a new game
- **UI**: "Quantidade de baralhos" selector on New Game screen
- **Range**: 1-4 decks, default 2
- **Database**: `number_of_decks` column in games table
- **Location**: `lib/screens/new_game_screen.dart:42-79`, `lib/models/game.dart:15`

### 3s Validation System
- **Feature**: Global validation for red and black 3s across all teams in a round
- **Logic**: Total 3s of each color cannot exceed (number_of_decks × 4)
- **UI**: + button automatically disables when limit reached for ANY team
- **Example**: With 2 decks, if Team 1 has 7 red 3s and Team 2 has 1 red 3, both teams' + buttons are disabled (7+1=8, max is 8)
- **Location**: `lib/screens/round_entry_screen.dart:102-124`, validation logic at 337, 347

### "Bateu" Selection Improvement
- **Old**: Individual checkbox on each team card
- **New**: Single radio button group at top asking "Qual time bateu?"
- **Options**: Each team + "Nenhum time bateu" (no team went out)
- **Location**: `lib/screens/round_entry_screen.dart:54-95`

### Multi-Select Player Addition
- **Old**: Click "Add Player" multiple times to add each player
- **New**: Check multiple players at once, then click "Confirmar"
- **UI**: CheckboxListTile for each player with Confirm button
- **Location**: `lib/screens/new_game_screen.dart:268-345`

### Auto-Load In-Progress Games
- **Feature**: Automatically loads in-progress game on app startup
- **Method**: `GameProvider.loadInProgressGame()` called in `initialize()`
- **Effect**: Home screen shows "Partida em Andamento" card if active game exists
- **Location**: `lib/providers/game_provider.dart:27-35`

### Score Breakdown Display
- **Feature**: Detailed score breakdown in round entry with Portuguese labels
- **Items**: Canastra Limpa, Canastra Suja, 3 Vermelhos, 3 Pretos, Pontos de Cartas, Cartas na Mão, Batida
- **Colors**: Green for positive points, red for negative
- **Location**: `lib/services/scoring_service.dart:44-84`, displayed in `round_entry_screen.dart`

### Provider Communication Fix (v1.2)
- **Fix**: Home screen now properly updates when a game is deleted from history
- **Implementation**: Added `clearGameIfMatches(gameId)` method to GameProvider
- **Location**: `lib/providers/game_provider.dart:198-204`
- **Usage**: Called in `lib/screens/history_screen.dart:106` after game deletion
- **Effect**: When deleting a game from history, both HistoryProvider and GameProvider are notified

### App Icon Setup (v1.3)
- **Package**: Added flutter_launcher_icons ^0.13.1 for automatic icon generation
- **Configuration**: Set up in pubspec.yaml with green background (#2E7D32) for adaptive icons
- **Requirements**: Need two 1024x1024 PNG files in `assets/icon/`
  - `app_icon.png` - Regular icon
  - `app_icon_foreground.png` - Adaptive icon foreground
- **Instructions**: Complete guide available at `assets/icon/ICON_INSTRUCTIONS.md`
- **Generation**: Run `flutter pub run flutter_launcher_icons` once icon files are added
- **Status**: Infrastructure ready, awaiting icon artwork

### UI Polish & Rule Adjustments (v1.4)
- **Terminology Update**: Changed "Jogo" → "Partida" throughout the app for more appropriate Brazilian Portuguese
- **Team Naming**: Changed "Time" → "Equipe" for team references
- **Card Point Values** (IMPORTANT - Rules Changed):
  - Joker: 50 → 20 points
  - Ace: 20 → 15 points
  - 2 (wild card): 20 → 10 points
- **Minimum Meld Requirements** (IMPORTANT - Rules Changed):
  - Removed "below 0" tier (was 15 points)
  - 0-1499: 50 → 45 points
  - 1500-2999: 90 → 75 points
  - 3000+: 120 → 90 points
- **UI Label Improvements**:
  - Removed point values from counter labels (e.g., "Limpa (200)" → "Limpa")
  - Changed "Pontos de Jogo" → "Pontos de Cartas" for clarity
  - More natural Portuguese phrasing (e.g., "Iniciado há" instead of "Iniciado")
  - Improved date formatting throughout (using DateFormat('yMd'))
- **Score Display Enhancements**:
  - Round breakdown now shows actual calculated points (cleanCanastas * 200, etc.)
  - Added Black 3s display in round details view
  - Removed "+" prefix from positive scores for cleaner appearance
- **Location**: Changes span across all screen files (game_screen.dart, home_screen.dart, new_game_screen.dart, history_screen.dart, round_entry_screen.dart) and lib/utils/canastra_rules.dart

## File Locations Reference

- Canastra rules constants: `lib/utils/canastra_rules.dart`
- Score calculation logic: `lib/services/scoring_service.dart:13-75`
- Database schema and migrations: `lib/services/database_service.dart:39-68` (migrations), `71-149` (schema)
- Current game state: `lib/providers/game_provider.dart`
- Round score input: `lib/screens/round_entry_screen.dart`
- Deck count selector: `lib/screens/new_game_screen.dart:42-79`
- 3s validation: `lib/screens/round_entry_screen.dart:102-124, 337, 347, 468`
