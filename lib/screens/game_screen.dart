import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
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
  late AnimationController _celebrationController;
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

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
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
    _celebrationController.dispose();
    super.dispose();
  }

  void _triggerCelebration() {
    _celebrationController.reset();
    _celebrationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, game, child) {
              // Trigger celebration on win
              if (game.isGameOver && game.winner != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_celebrationController.isAnimating &&
                      _celebrationController.status !=
                          AnimationStatus.completed) {
                    _triggerCelebration();
                  }
                });
              }

              return Stack(
                children: [
                  // Main content
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide
                              ? size.width * 0.15
                              : AppSizes.padding,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),

                            // Header with back button
                            _buildHeader(context, game),

                            const SizedBox(height: 24),

                            // Score board
                            _buildScoreBoard(game),

                            const SizedBox(height: 24),

                            // Current player indicator
                            _buildTurnIndicator(game),

                            const SizedBox(height: 24),

                            // Game board
                            _buildGameBoard(game),

                            const SizedBox(height: 32),

                            // Reset button
                            _buildResetButton(context, game),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Celebration particles
                  if (game.isGameOver && game.winner != null)
                    _buildCelebration(game.winner!),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCelebration(Player winner) {
    final color = winner == Player.x ? AppColors.playerX : AppColors.playerO;

    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        if (_celebrationController.value == 0) return const SizedBox();

        return IgnorePointer(
          child: Stack(
            children: List.generate(30, (index) {
              final random = math.Random(index);
              final startX =
                  random.nextDouble() * MediaQuery.of(context).size.width;
              final startY = -50.0 - random.nextDouble() * 100;
              final endY = MediaQuery.of(context).size.height + 50;
              final drift = (random.nextDouble() - 0.5) * 200;
              final size = 8.0 + random.nextDouble() * 12;
              final delay = random.nextDouble() * 0.3;

              final progress =
                  ((_celebrationController.value - delay) / (1 - delay)).clamp(
                    0.0,
                    1.0,
                  );

              return Positioned(
                left: startX + drift * progress,
                top: startY + (endY - startY) * progress,
                child: Opacity(
                  opacity: (1 - progress).clamp(0, 1),
                  child: Transform.rotate(
                    angle: progress * math.pi * 4,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: index % 3 == 0
                            ? color
                            : index % 3 == 1
                            ? AppColors.winLine
                            : Colors.white,
                        shape: index % 2 == 0
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius: index % 2 == 1
                            ? BorderRadius.circular(2)
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameProvider game) {
    return Row(
      children: [
        // Back button
        _buildIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () {
            game.resetScores();
            Navigator.pop(context);
          },
        ),

        const Spacer(),

        // Game mode label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.gridLine, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                game.gameMode == GameMode.vsAI
                    ? Icons.smart_toy_rounded
                    : Icons.people_alt_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                game.gameMode == GameMode.vsAI ? 'VS AI' : '2 Players',
                style: TextStyle(fontFamily: 'Orbitron',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Difficulty selector (only for AI mode)
        if (game.gameMode == GameMode.vsAI)
          _buildDifficultySelector(game)
        else
          const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gridLine, width: 1),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(GameProvider game) {
    return PopupMenuButton<Difficulty>(
      tooltip: 'Change Difficulty',
      offset: const Offset(0, 50),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gridLine, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.tune_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              _getDifficultyEmoji(game.difficulty),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (difficulty) => game.setDifficulty(difficulty),
      itemBuilder: (context) => [
        _buildDifficultyItem(Difficulty.easy, '😊 Easy', game.difficulty),
        _buildDifficultyItem(Difficulty.medium, '🤔 Medium', game.difficulty),
        _buildDifficultyItem(Difficulty.hard, '🔥 Hard', game.difficulty),
      ],
    );
  }

  String _getDifficultyEmoji(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '😊';
      case Difficulty.medium:
        return '🤔';
      case Difficulty.hard:
        return '🔥';
    }
  }

  PopupMenuItem<Difficulty> _buildDifficultyItem(
    Difficulty value,
    String label,
    Difficulty current,
  ) {
    final isSelected = current == value;
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(fontFamily: 'Poppins',
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard(GameProvider game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gridLine, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreCard(
            label: 'X',
            score: game.scoreX,
            color: AppColors.playerX,
            isActive: game.currentPlayer == Player.x && !game.isGameOver,
            isWinner: game.winner == Player.x,
          ),
          Container(width: 1, height: 50, color: AppColors.gridLine),
          _buildScoreCard(
            label: 'Draw',
            score: game.draws,
            color: AppColors.textSecondary,
            isActive: false,
            isWinner: game.isDraw,
          ),
          Container(width: 1, height: 50, color: AppColors.gridLine),
          _buildScoreCard(
            label: game.gameMode == GameMode.vsAI ? 'AI' : 'O',
            score: game.scoreO,
            color: AppColors.playerO,
            isActive: game.currentPlayer == Player.o && !game.isGameOver,
            isWinner: game.winner == Player.o,
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
    required bool isWinner,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: AppDurations.medium,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isActive || isWinner
              ? color.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontFamily: 'Orbitron',
                color: isActive || isWinner ? color : AppColors.textSecondary,
                fontSize: isActive ? 13 : 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              score.toString(),
              style: TextStyle(fontFamily: 'Orbitron',
                color: color,
                fontSize: isWinner ? 30 : 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnIndicator(GameProvider game) {
    String message;
    Color color;
    IconData? icon;

    if (game.isGameOver) {
      if (game.winner != null) {
        if (game.gameMode == GameMode.vsAI && game.winner == Player.o) {
          message = 'AI Wins!';
          icon = Icons.smart_toy_rounded;
        } else {
          message = 'Player ${game.winner == Player.x ? 'X' : 'O'} Wins!';
          icon = Icons.emoji_events_rounded;
        }
        color = game.winner == Player.x ? AppColors.playerX : AppColors.playerO;
      } else {
        message = "It's a Draw!";
        icon = Icons.handshake_rounded;
        color = AppColors.textSecondary;
      }
    } else if (game.isAiThinking) {
      message = 'AI is thinking...';
      icon = Icons.psychology_rounded;
      color = AppColors.playerO;
    } else {
      message = 'Player ${game.currentPlayer == Player.x ? 'X' : 'O'}\'s Turn';
      icon = null;
      color = game.currentPlayer == Player.x
          ? AppColors.playerX
          : AppColors.playerO;
    }

    return AnimatedSwitcher(
      duration: AppDurations.medium,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(message),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard(GameProvider game) {
    return ScaleTransition(
      scale: _boardScaleAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate board size based on available space
          final maxSize = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;
          final boardSize = maxSize.clamp(280.0, 380.0);

          return Container(
            width: boardSize,
            height: boardSize,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gridLine, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Grid of tiles
                Column(
                  children: [
                    for (int row = 0; row < 3; row++)
                      Expanded(
                        child: Row(
                          children: [
                            for (int col = 0; col < 3; col++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: GameTile(
                                    player: game.board[row * 3 + col],
                                    onTap: () => game.makeMove(row * 3 + col),
                                    isWinningTile:
                                        game.winningLine?.contains(
                                          row * 3 + col,
                                        ) ??
                                        false,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Winning line overlay
                if (game.winningLine != null)
                  WinningLine(winningLine: game.winningLine!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, GameProvider game) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          game.resetGame();
          _boardController.reset();
          _boardController.forward();
          _celebrationController.reset();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'NEW GAME',
                style: TextStyle(fontFamily: 'Orbitron',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



