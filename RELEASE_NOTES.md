# Canastracker Release Notes 🃏

## Version 1.1.0 (Current)

### 🎨 UI Polish & Terminology
- **Better Portuguese**: Changed "Jogo" → "Partida" throughout the app for more appropriate Brazilian Portuguese
- **Team Terminology**: Updated "Time" → "Equipe" for team references
- **Cleaner Labels**: Removed point values from counter labels (e.g., "Limpa (200)" → "Limpa")
- **Natural Phrasing**: Improved Portuguese throughout (e.g., "Iniciado há" instead of "Iniciado")
- **Better Formatting**: Improved date display using DateFormat('yMd')
- **Label Clarity**: Changed "Pontos de Jogo" → "Pontos de Cartas" for better understanding

### ⚖️ Rule Adjustments
**IMPORTANT: Card point values have been adjusted to better match traditional Brazilian Canastra**

#### Card Point Values Changed:
- **Joker**: 50 → 20 points
- **Ace**: 20 → 15 points
- **2 (wild card)**: 20 → 10 points
- Other cards remain unchanged (K-8: 10pts, 7-4: 5pts)

#### Minimum Meld Requirements Changed:
- **0-1,499 points**: 50 → 45 points
- **1,500-2,999 points**: 90 → 75 points
- **3,000+ points**: 120 → 90 points
- Removed "below 0" tier (was 15 points)

### 📊 Display Improvements
- **Score Breakdown**: Round details now show actual calculated points (e.g., 3 Canastras Limpas = 600 points)
- **Black 3s Display**: Added Black 3s to round detail view for complete transparency
- **Cleaner Numbers**: Removed "+" prefix from positive scores for simpler display

### 🐛 Bug Fixes
- Minor UI alignment improvements across all screens
- More consistent terminology throughout the app

---

## Version 1.0.0

First stable release of Canastracker - A score tracking app for Brazilian Canastra card game!

## ✨ Features

### Game Management
- **Player Management**: Create and manage players with persistent game statistics
- **Multi-Team Setup**: Support for 2-4 teams with multi-select player addition
- **Configurable Decks**: Play with 1-4 decks (default: 2 decks)
- **Auto-Resume**: Automatically loads in-progress games on app start

### Brazilian Canastra Rules
- **Clean Canastas**: 200 points (Canastra Limpa)
- **Dirty Canastas**: 100 points (Canastra Suja)
- **Red 3s**: +100 points each (always positive, no penalty)
- **Black 3s**: -100 points penalty each
- **Going Out Bonus**: 100 points (Batida)
- **Target Score**: 3000 points (fixed)
- **Minimum Meld**: Varies by current score (45/75/90 points in v1.1.0+)

### Smart Features
- **Global 3s Validation**: Total red/black 3s across all teams cannot exceed deck limit
- **Single "Bateu" Selector**: Radio button selection for which team went out
- **Live Score Breakdown**: Real-time detailed point calculation display
- **Automatic Calculations**: All scoring done automatically based on Brazilian rules

### User Experience
- **Complete Portuguese UI**: Entire interface in Portuguese (Brazil)
- **Game History**: View all completed and in-progress games
- **Round-by-Round Details**: See complete breakdown of each round
- **Material Design 3**: Modern, clean Android interface
- **Custom App Icon**: Playing cards design with adaptive icons for Android 8.0+

## 🛠️ Technical Details

- **Framework**: Flutter 3.35.7
- **Language**: Dart 3.9.2
- **State Management**: Provider pattern with ChangeNotifier
- **Database**: SQLite with migration support (version 5)
- **UI**: Material Design 3
- **Target**: Android (API 21+)
- **Build**: Android Gradle Plugin 8.7.3, Gradle 8.11

## 📱 Installation

Download the APK from the releases and install on your Android device (requires Android 5.0+ / API 21).

## 📖 Documentation

- **README.md**: User guide and game rules
- **ARCHITECTURE.md**: Complete technical documentation
- **CLAUDE.md**: Developer guide for Claude Code

## 🎯 What's Next

Future improvements planned:
- Round editing and deletion
- Export game summaries (CSV/PDF)
- Cloud sync support
- Additional statistics and analytics
- iOS support

## 🤝 Credits

Built with [Claude Code](https://claude.com/claude-code)

---

**Full Changelog**: https://github.com/stiksy/canastracker/commits/v1.0.0
