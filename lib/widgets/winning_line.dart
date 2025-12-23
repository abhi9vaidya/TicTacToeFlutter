import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Animated winning line that draws across the winning tiles
class WinningLine extends StatefulWidget {
  final List<int> winningLine;

  const WinningLine({
    super.key,
    required this.winningLine,
  });

  @override
  State<WinningLine> createState() => _WinningLineState();
}

class _WinningLineState extends State<WinningLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AppDurations.winLine,
      vsync: this,
    );
    
    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WinningLinePainter(
            winningLine: widget.winningLine,
            progress: _lineAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter for the winning line
class WinningLinePainter extends CustomPainter {
  final List<int> winningLine;
  final double progress;

  WinningLinePainter({
    required this.winningLine,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (winningLine.isEmpty) return;
    
    final paint = Paint()
      ..color = AppColors.winLine
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Add glow effect
    final glowPaint = Paint()
      ..color = AppColors.winLine.withOpacity(0.3)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Calculate tile size (3x3 grid)
    final tileWidth = size.width / 3;
    final tileHeight = size.height / 3;

    // Get start and end positions
    final startTile = winningLine.first;
    final endTile = winningLine.last;

    // Calculate center points
    Offset getCenter(int index) {
      final row = index ~/ 3;
      final col = index % 3;
      return Offset(
        col * tileWidth + tileWidth / 2,
        row * tileHeight + tileHeight / 2,
      );
    }

    final start = getCenter(startTile);
    final end = getCenter(endTile);

    // Animate the line
    final currentEnd = Offset(
      start.dx + (end.dx - start.dx) * progress,
      start.dy + (end.dy - start.dy) * progress,
    );

    // Draw glow
    canvas.drawLine(start, currentEnd, glowPaint);
    
    // Draw line
    canvas.drawLine(start, currentEnd, paint);
  }

  @override
  bool shouldRepaint(WinningLinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.winningLine != winningLine;
}
