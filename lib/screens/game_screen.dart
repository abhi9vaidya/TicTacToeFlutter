import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../widgets/game_tile.dart';
import '../widgets/winning_line.dart';

/// Main game screen with board and controls
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _boardController;
  late Animation<double> _boardScaleAnimation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    
    _boardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _boardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _boardController, curve: Curves.elasticOut),
    );
    
    _boardController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_initialized) {
      final mode = ModalRoute.of(context)?.settings.arguments as GameMode?;
      if (mode != null) {
        Future.microtask(() {
          context.read<GameProvider>().setGameMode(mode);
        });
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, game, child) {
              return Column(
                children: [
                  // Header with back button
                  _buildHeader(context, game),
                  
                  const Spacer(),
                  
                  // Score board
                  _buildScoreBoard(game),
                  
                  const SizedBox(height: 30),
                  
                  // Current player indicator
                  _buildTurnIndicator(game),
                  
                  const SizedBox(height: 30),
                  
                  // Game board
                  _buildGameBoard(game),
                  
                  const Spacer(),
                  
                  // Reset button
                  _buildResetButton(context, game),
                  
                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameProvider game) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              game.resetScores();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Game mode label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              game.gameMode == GameMode.vsAI ? '🤖 VS AI' : '👥 2 Players',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Difficulty selector (only for AI mode)
          if (game.gameMode == GameMode.vsAI)
            _buildDifficultySelector(game)
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(GameProvider game) {
    return PopupMenuButton<Difficulty>(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.tune,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (difficulty) => game.setDifficulty(difficulty),
      itemBuilder: (context) => [
        _buildDifficultyItem(Difficulty.easy, '😊 Easy', game.difficulty),
        _buildDifficultyItem(Difficulty.medium, '🤔 Medium', game.difficulty),
        _buildDifficultyItem(Difficulty.hard, '🔥 Hard', game.difficulty),
      ],
    );
  }

  PopupMenuItem<Difficulty> _buildDifficultyItem(
    Difficulty value,
    String label,
    Difficulty current,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: current == value ? AppColors.primary : AppColors.textPrimary,
              fontWeight: current == value ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (current == value) ...[
            const Spacer(),
            const Icon(Icons.check, color: AppColors.primary, size: 18),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBoard(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreCard(
            label: 'Player X',
            score: game.scoreX,
            color: AppColors.playerX,
            isActive: game.currentPlayer == Player.x && !game.isGameOver,
          ),
          _buildScoreCard(
            label: 'Draws',
            score: game.draws,
            color: AppColors.textSecondary,
            isActive: false,
          ),
          _buildScoreCard(
            label: game.gameMode == GameMode.vsAI ? 'AI' : 'Player O',
            score: game.scoreO,
            color: AppColors.playerO,
            isActive: game.currentPlayer == Player.o && !game.isGameOver,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required String label,
    required int score,
    required Color color,
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: AppDurations.medium,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(
          color: isActive ? color : Colors.transparent,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(GameProvider game) {
    String message;
    Color color;
    
    if (game.isGameOver) {
      if (game.winner != null) {
        if (game.gameMode == GameMode.vsAI && game.winner == Player.o) {
          message = '🤖 AI Wins!';
        } else {
          message = '🎉 Player ${game.winner == Player.x ? 'X' : 'O'} Wins!';
        }
        color = game.winner == Player.x ? AppColors.playerX : AppColors.playerO;
      } else {
        message = "🤝 It's a Draw!";
        color = AppColors.textSecondary;
      }
    } else if (game.isAiThinking) {
      message = '🤔 AI is thinking...';
      color = AppColors.playerO;
    } else {
      if (game.gameMode == GameMode.vsAI && game.currentPlayer == Player.o) {
        message = '🤖 AI Turn';
      } else {
        message = '${game.currentPlayer == Player.x ? '❌' : '⭕'} Player ${game.currentPlayer == Player.x ? 'X' : 'O'}\'s Turn';
      }
      color = game.currentPlayer == Player.x ? AppColors.playerX : AppColors.playerO;
    }
    
    return AnimatedSwitcher(
      duration: AppDurations.medium,
      child: Text(
        message,
        key: ValueKey(message),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildGameBoard(GameProvider game) {
    return ScaleTransition(
      scale: _boardScaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.gridSpacing),
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              // Grid of tiles
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSizes.gridSpacing,
                  crossAxisSpacing: AppSizes.gridSpacing,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GameTile(
                    player: game.board[index],
                    onTap: () => game.makeMove(index),
                    isWinningTile: game.winningLine?.contains(index) ?? false,
                  );
                },
              ),
              
              // Winning line overlay
              if (game.winningLine != null)
                WinningLine(winningLine: game.winningLine!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, GameProvider game) {
    return GestureDetector(
      onTap: () {
        game.resetGame();
        _boardController.reset();
        _boardController.forward();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'NEW GAME',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
