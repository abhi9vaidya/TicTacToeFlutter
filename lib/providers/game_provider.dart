import 'dart:math';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

/// Game state provider managing all game logic
class GameProvider extends ChangeNotifier {
  // Board state: 9 tiles (0-8), row-major order
  List<Player> _board = List.filled(9, Player.none);
  
  // Current player
  Player _currentPlayer = Player.x;
  
  // Game mode
  GameMode _gameMode = GameMode.twoPlayer;
  
  // AI difficulty
  Difficulty _difficulty = Difficulty.medium;
  
  // Scores
  int _scoreX = 0;
  int _scoreO = 0;
  int _draws = 0;
  
  // Winner and winning line
  Player? _winner;
  List<int>? _winningLine;
  
  // Game state flags
  bool _isGameOver = false;
  bool _isAiThinking = false;
  
  // Getters
  List<Player> get board => _board;
  Player get currentPlayer => _currentPlayer;
  GameMode get gameMode => _gameMode;
  Difficulty get difficulty => _difficulty;
  int get scoreX => _scoreX;
  int get scoreO => _scoreO;
  int get draws => _draws;
  Player? get winner => _winner;
  List<int>? get winningLine => _winningLine;
  bool get isGameOver => _isGameOver;
  bool get isAiThinking => _isAiThinking;
  bool get isDraw => _isGameOver && _winner == null;
  
  /// Set game mode
  void setGameMode(GameMode mode) {
    _gameMode = mode;
    resetGame();
    notifyListeners();
  }
  
  /// Set AI difficulty
  void setDifficulty(Difficulty diff) {
    _difficulty = diff;
    notifyListeners();
  }
  
  /// Make a move at the given index
  Future<void> makeMove(int index) async {
    // Validate move
    if (_board[index] != Player.none || _isGameOver || _isAiThinking) {
      return;
    }
    
    // Place the mark
    _board[index] = _currentPlayer;
    notifyListeners();
    
    // Check for winner
    if (_checkWinner()) {
      _handleGameEnd();
      return;
    }
    
    // Check for draw
    if (_isBoardFull()) {
      _isGameOver = true;
      _draws++;
      notifyListeners();
      return;
    }
    
    // Switch player
    _currentPlayer = _currentPlayer == Player.x ? Player.o : Player.x;
    notifyListeners();
    
    // AI move if applicable
    if (_gameMode == GameMode.vsAI && _currentPlayer == Player.o && !_isGameOver) {
      await _makeAiMove();
    }
  }
  
  /// AI makes a move
  Future<void> _makeAiMove() async {
    _isAiThinking = true;
    notifyListeners();
    
    // Add delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    int move;
    switch (_difficulty) {
      case Difficulty.easy:
        move = _getRandomMove();
        break;
      case Difficulty.medium:
        // 50% chance of optimal move
        move = Random().nextBool() ? _getBestMove() : _getRandomMove();
        break;
      case Difficulty.hard:
        move = _getBestMove();
        break;
    }
    
    _isAiThinking = false;
    
    if (move != -1) {
      _board[move] = Player.o;
      notifyListeners();
      
      if (_checkWinner()) {
        _handleGameEnd();
        return;
      }
      
      if (_isBoardFull()) {
        _isGameOver = true;
        _draws++;
        notifyListeners();
        return;
      }
      
      _currentPlayer = Player.x;
      notifyListeners();
    }
  }
  
  /// Get random available move
  int _getRandomMove() {
    List<int> available = [];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == Player.none) {
        available.add(i);
      }
    }
    if (available.isEmpty) return -1;
    return available[Random().nextInt(available.length)];
  }
  
  /// Get best move using Minimax algorithm
  int _getBestMove() {
    int bestScore = -1000;
    int bestMove = -1;
    
    for (int i = 0; i < 9; i++) {
      if (_board[i] == Player.none) {
        _board[i] = Player.o;
        int score = _minimax(false, 0);
        _board[i] = Player.none;
        
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    
    return bestMove;
  }
  
  /// Minimax algorithm
  int _minimax(bool isMaximizing, int depth) {
    Player? result = _checkWinnerForMinimax();
    
    if (result == Player.o) return 10 - depth;
    if (result == Player.x) return depth - 10;
    if (_isBoardFull()) return 0;
    
    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i] == Player.none) {
          _board[i] = Player.o;
          int score = _minimax(false, depth + 1);
          _board[i] = Player.none;
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i] == Player.none) {
          _board[i] = Player.x;
          int score = _minimax(true, depth + 1);
          _board[i] = Player.none;
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }
  
  /// Winning combinations
  static const List<List<int>> _winPatterns = [
    [0, 1, 2], // Top row
    [3, 4, 5], // Middle row
    [6, 7, 8], // Bottom row
    [0, 3, 6], // Left column
    [1, 4, 7], // Middle column
    [2, 5, 8], // Right column
    [0, 4, 8], // Diagonal
    [2, 4, 6], // Anti-diagonal
  ];
  
  /// Check for winner and set winning line
  bool _checkWinner() {
    for (var pattern in _winPatterns) {
      if (_board[pattern[0]] != Player.none &&
          _board[pattern[0]] == _board[pattern[1]] &&
          _board[pattern[1]] == _board[pattern[2]]) {
        _winner = _board[pattern[0]];
        _winningLine = pattern;
        return true;
      }
    }
    return false;
  }
  
  /// Check winner for minimax (without side effects)
  Player? _checkWinnerForMinimax() {
    for (var pattern in _winPatterns) {
      if (_board[pattern[0]] != Player.none &&
          _board[pattern[0]] == _board[pattern[1]] &&
          _board[pattern[1]] == _board[pattern[2]]) {
        return _board[pattern[0]];
      }
    }
    return null;
  }
  
  /// Check if board is full
  bool _isBoardFull() {
    return !_board.contains(Player.none);
  }
  
  /// Handle game end
  void _handleGameEnd() {
    _isGameOver = true;
    if (_winner == Player.x) {
      _scoreX++;
    } else if (_winner == Player.o) {
      _scoreO++;
    }
    notifyListeners();
  }
  
  /// Reset the game board
  void resetGame() {
    _board = List.filled(9, Player.none);
    _currentPlayer = Player.x;
    _winner = null;
    _winningLine = null;
    _isGameOver = false;
    _isAiThinking = false;
    notifyListeners();
  }
  
  /// Reset all scores
  void resetScores() {
    _scoreX = 0;
    _scoreO = 0;
    _draws = 0;
    resetGame();
  }
}
