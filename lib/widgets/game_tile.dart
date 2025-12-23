import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../screens/home_screen.dart';

/// Animated game tile with X and O drawing animations
class GameTile extends StatefulWidget {
  final Player player;
  final VoidCallback onTap;
  final bool isWinningTile;

  const GameTile({
    super.key,
    required this.player,
    required this.onTap,
    this.isWinningTile = false,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _drawAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppDurations.xDraw,
      vsync: this,
    );

    _drawAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    if (widget.player != Player.none) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Player changed from none to X or O
    if (oldWidget.player == Player.none && widget.player != Player.none) {
      _controller.reset();
      _controller.forward();
    }

    // Board was reset
    if (widget.player == Player.none && oldWidget.player != Player.none) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.player == Player.none;

    return MouseRegion(
      cursor: isEmpty ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isEmpty ? widget.onTap : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AnimatedContainer(
              duration: AppDurations.fast,
              decoration: BoxDecoration(
                color: _getTileColor(),
                borderRadius: BorderRadius.circular(16),
                border: widget.isWinningTile
                    ? Border.all(color: AppColors.winLine, width: 3)
                    : Border.all(color: AppColors.gridLine, width: 1),
                boxShadow: [
                  if (widget.isWinningTile)
                    BoxShadow(
                      color: AppColors.winLine.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  else if (_isHovered && isEmpty)
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Transform.scale(
                scale: widget.player != Player.none ? _scaleAnimation.value : 1,
                child: CustomPaint(
                  painter: _getTilePainter(),
                  size: Size.infinite,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getTileColor() {
    if (widget.isWinningTile) {
      return AppColors.winLine.withOpacity(0.1);
    }
    if (_isHovered && widget.player == Player.none) {
      return AppColors.surfaceLight.withOpacity(0.8);
    }
    return AppColors.surfaceLight;
  }

  CustomPainter? _getTilePainter() {
    switch (widget.player) {
      case Player.x:
        return XPainter(
          color: widget.isWinningTile ? AppColors.winLine : AppColors.playerX,
          progress: _drawAnimation.value,
        );
      case Player.o:
        return OPainter(
          color: widget.isWinningTile ? AppColors.winLine : AppColors.playerO,
          progress: _drawAnimation.value,
        );
      case Player.none:
        return null;
    }
  }
}
