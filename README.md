# Canastracker 🃏

A Flutter Android application for tracking scores in **Canastra**, the beloved Brazilian card game. Keep accurate scores, manage players and teams, and focus on the game while the app handles all the calculations.

## About Canastra

Canastra is a popular Brazilian variant of Canasta, a rummy-style card game played with two standard decks. The objective is to form melds (sets of cards) and create **canastas** (sets of seven or more cards) to score points. The game involves strategy, memory, and partnership play, making it a favorite for family gatherings and social events throughout Brazil.

Key aspects of the game:
- **Teams**: Usually played with 2-4 teams of 2 players each
- **Scoring**: Points are earned through canastas, red 3s, melds, and going out
- **Winning**: First team to reach 3000 points wins
- **Strategy**: Balancing offensive play (forming canastas) with defensive play (blocking opponents)

## Features

- **Player Management**: Create and manage players with persistent game statistics
- **Multi-Select Team Setup**: Quickly add multiple players to teams with checkbox selection
- **Configurable Deck Count**: Play with 1-4 decks (default: 2 decks)
- **Round-by-Round Tracking**: Enter detailed scores for each round including:
  - Clean Canastas (Canastra Limpa) - 200 points
  - Dirty Canastas (Canastra Suja) - 100 points
  - Red 3s (3 Vermelhos) - Always +100 points each
  - Black 3s (3 Pretos) - -100 points penalty each
  - Meld points (Pontos de Jogo)
  - Cards in hand deductions (Cartas na Mão)
  - Going out bonus (Batida) - 100 points
- **Smart Validation**: Automatic 3s tracking prevents invalid entries (can't exceed deck limits)
- **Live Score Breakdown**: See detailed point breakdown for each team in real-time
- **Automatic Score Calculation**: Based on Brazilian Canastra rules
- **Game History**: View all completed and in-progress games
- **Auto-Resume**: Automatically loads in-progress game when app starts
- **Portuguese Interface**: Entire UI in Portuguese (Brazil)

## Installation

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio (for Android development)

### Setup
```bash
# Clone the repository
git clone <repository-url>
cd canastracker

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

## How to Use

### First Time Setup
1. **Create Players**: Tap "Gerenciar Jogadores" (Manage Players) from the home screen
2. **Add Player Names**: Enter names for all players who will participate in games
3. Players are saved permanently and can be reused across multiple games

### Starting a New Game
1. **Tap "Novo Jogo"** (New Game) from the home screen
2. **Configure Game Settings**:
   - Set "Quantidade de baralhos" (Number of decks): 1-4 decks (default: 2)
3. **Set Up Teams**:
   - Enter team names (default: Time 1, Time 2)
   - Tap "Adicionar Jogador" (Add Player) for each team
   - Use checkboxes to select multiple players at once
   - Click "Confirmar" (Confirm) to add selected players
   - Add 2-4 teams (minimum 2 teams required)
4. **Tap "Iniciar Jogo"** (Start Game) when ready

### Playing a Game
1. **From the Game Screen**, tap "Adicionar Rodada" (Add Round) to start scoring
2. **At the top**, select "Qual time bateu?" (Which team went out?):
   - Select the team that went out, or
   - Select "Nenhum time bateu" (No team went out) if round ended without anyone going out
3. **For Each Team**, enter:
   - **Canastas**: Limpa (Clean) and Suja (Dirty) counts
   - **3 Vermelhos**: Number of red 3s (max limited by deck count)
   - **3 Pretos**: Number of black 3s (max limited by deck count)
   - **Pontos de Jogo**: Meld points value
   - **Cartas na Mão**: Point value of cards still in hand
4. **View Breakdown**: See real-time score calculation in "Detalhamento" section
5. **Tap "Salvar Rodada"** (Save Round) to record the round

### During the Game
- **View Current Scores**: See cumulative scores for all teams
- **Track Rounds**: View all previous rounds and their scores
- **Automatic Win Detection**: Game ends automatically when a team reaches 3000 points
- **Batida Bonus**: 100 points automatically added to the team that went out

### After the Game
- **View Winner**: See which team won and final scores
- **Game History**: Access past games from "Histórico" (History) on home screen
- **Resume Games**: In-progress games automatically appear on home screen for quick access

### Tips
- **Smart Validation**: The app prevents invalid 3s entries - if both teams combined have reached the maximum red 3s (decks × 4), the + button disables
- **Live Calculations**: Score breakdown updates in real-time as you enter values
- **Persistent Data**: All players, games, and scores are saved to local database

## Canastra Rules (Brazilian Variant)

The app implements Brazilian Canastra scoring rules:

### Canasta Bonuses
- **Canastra Limpa** (Clean Canasta - no wild cards): **200 points**
- **Canastra Suja** (Dirty Canasta - with wild cards): **100 points**

### Special Cards
- **3 Vermelhos** (Red 3s): **+100 points each** (always positive, no penalty)
- **3 Pretos** (Black 3s): **-100 points each** (always penalty)
- Maximum 3s per color = Number of decks × 4 (e.g., 2 decks = 8 red 3s max total across all teams)

### Card Values (for Melds)
- Joker: 50 points | Ace: 20 points | 2 (wild): 20 points
- K, Q, J, 10, 9, 8: 10 points each
- 7, 6, 5, 4: 5 points each

### Other Scoring
- **Batida** (Going out): **100 points**
- **Pontos de Jogo** (Meld points): Sum of card values in melds
- **Cartas na Mão** (Cards in hand): Point value deducted from score
- **Abertura Mínima** (Minimum meld): Varies by current score (15/50/90/120 points)

### Winning Conditions
- **Target score**: **3000 points** (fixed)
- Must have at least 2 canastas to go out, one must be clean
- Game ends when any team reaches or exceeds 3000 points

## Development

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Build release APK
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── player.dart             # Player entity with stats
│   ├── team.dart               # Team with player list
│   ├── game.dart               # Game with teams and rounds
│   └── round.dart              # Round and RoundScore entities
├── providers/                   # State management (Provider pattern)
│   ├── game_provider.dart      # Current game state & operations
│   └── history_provider.dart   # Game history & statistics
├── screens/                     # UI screens (Material Design 3)
│   ├── home_screen.dart        # Main menu
│   ├── new_game_screen.dart    # Game setup with team/deck config
│   ├── game_screen.dart        # Active game view
│   ├── round_entry_screen.dart # Score input per round
│   └── history_screen.dart     # Past games list
├── services/                    # Business logic layer
│   ├── database_service.dart   # SQLite CRUD operations
│   └── scoring_service.dart    # Score calculation logic
└── utils/                       # Constants and utilities
    └── canastra_rules.dart     # Game rules and point values
```

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

## License

This project is open source and available under the MIT License.
