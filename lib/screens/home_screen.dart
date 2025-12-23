import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Animated home screen with game mode selection
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _buttonsController;
  late Animation<double> _titleAnimation;
  late Animation<double> _titleGlowAnimation;
  late Animation<Offset> _button1SlideAnimation;
  late Animation<Offset> _button2SlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _titleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );
    
    _titleGlowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );
    
    // Button animations
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _button1SlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
    
    _button2SlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _buttonFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeIn),
    );
    
    // Start animations
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonsController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonsController.dispose();
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
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Animated title
                _buildAnimatedTitle(),
                
                const Spacer(flex: 1),
                
                // Animated X and O icons
                _buildGameIcons(),
                
                const Spacer(flex: 2),
                
                // Mode selection buttons
                _buildModeButtons(),
                
                const Spacer(flex: 1),
                
                // Credits
                _buildCredits(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _titleAnimation.value,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
                AppColors.primary,
              ],
              stops: [
                0,
                _titleGlowAnimation.value,
                1,
              ],
            ).createShader(bounds),
            child: const Text(
              'TIC TAC TOE',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameIcons() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        return Opacity(
          opacity: _titleAnimation.value.clamp(0, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // X icon
              _buildXIcon(),
              const SizedBox(width: 40),
              // O icon
              _buildOIcon(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildXIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.playerX.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: XPainter(color: AppColors.playerX, progress: 1),
      ),
    );
  }

  Widget _buildOIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.playerO.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: OPainter(color: AppColors.playerO, progress: 1),
      ),
    );
  }

  Widget _buildModeButtons() {
    return Column(
      children: [
        // Two Player button
        SlideTransition(
          position: _button1SlideAnimation,
          child: FadeTransition(
            opacity: _buttonFadeAnimation,
            child: _buildModeButton(
              icon: Icons.people,
              label: '2 PLAYERS',
              gradient: AppColors.primaryGradient,
              onTap: () => _startGame(GameMode.twoPlayer),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // VS AI button
        SlideTransition(
          position: _button2SlideAnimation,
          child: FadeTransition(
            opacity: _buttonFadeAnimation,
            child: _buildModeButton(
              icon: Icons.smart_toy,
              label: 'VS AI',
              gradient: AppColors.secondaryGradient,
              onTap: () => _startGame(GameMode.vsAI),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredits() {
    return const Text(
      'Made with Flutter ❤️',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
    );
  }

  void _startGame(GameMode mode) {
    Navigator.pushNamed(context, '/game', arguments: mode);
  }
}

/// Custom painter for X mark
class XPainter extends CustomPainter {
  final Color color;
  final double progress;

  XPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final padding = size.width * 0.2;
    
    // First line of X
    if (progress > 0) {
      final p1 = progress.clamp(0, 0.5) * 2;
      canvas.drawLine(
        Offset(padding, padding),
        Offset(
          padding + (size.width - 2 * padding) * p1,
          padding + (size.height - 2 * padding) * p1,
        ),
        paint,
      );
    }
    
    // Second line of X
    if (progress > 0.5) {
      final p2 = (progress - 0.5) * 2;
      canvas.drawLine(
        Offset(size.width - padding, padding),
        Offset(
          size.width - padding - (size.width - 2 * padding) * p2,
          padding + (size.height - 2 * padding) * p2,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(XPainter oldDelegate) => oldDelegate.progress != progress;
}

/// Custom painter for O mark
class OPainter extends CustomPainter {
  final Color color;
  final double progress;

  OPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.6;
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * 3.14159 * progress;
    
    canvas.drawArc(rect, -3.14159 / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(OPainter oldDelegate) => oldDelegate.progress != progress;
}
