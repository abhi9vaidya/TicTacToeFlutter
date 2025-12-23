# 🎮 Tic Tac Toe Flutter

A simple animated Tic Tac Toe game built with Flutter featuring smooth animations, AI opponent with difficulty levels, and a stunning neon cyberpunk theme.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features

- **🎨 Stunning UI** - Neon cyberpunk dark theme with smooth gradients
- **🎯 Two Game Modes**
  - 2 Players - Play with a friend
  - VS AI - Challenge the computer
- **🤖 AI Difficulty Levels**
  - Easy - Random moves
  - Medium - Mix of random and optimal
  - Hard - Unbeatable minimax algorithm
- **🎬 Smooth Animations**
  - X and O drawing animations
  - Winning line animation with glow effect
  - Score board transitions
  - Board scale animations
- **📊 Score Tracking** - Keeps track of wins and draws
- **🔄 Quick Reset** - Start a new game instantly

## 🛠️ Tech Stack

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Provider** - State management
- **Custom Painters** - For X, O, and winning line animations

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers/
│   └── game_provider.dart    # Game state & logic
├── screens/
│   ├── home_screen.dart      # Main menu
│   └── game_screen.dart      # Game board
├── widgets/
│   ├── game_tile.dart        # Animated tile
│   └── winning_line.dart     # Win line animation
└── utils/
    ├── constants.dart        # Colors, sizes, etc.
    └── theme.dart            # App theme config
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/abhi9vaidya/TicTacToeFlutter.git
```

2. Navigate to project directory:
```bash
cd TicTacToeFlutter
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## 🎮 How to Play

1. Choose your game mode (2 Players or VS AI)
2. If playing VS AI, select difficulty from the settings icon
3. Tap on any empty tile to make your move
4. First player to get 3 in a row wins!
5. Tap "NEW GAME" to restart

## 🎨 Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Cyan | `#00F5FF` | Player X |
| Magenta | `#FF00E5` | Player O |
| Yellow | `#FFE500` | Winning line |
| Dark Blue | `#0A0E17` | Background |

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

Made with ❤️ and Flutter
