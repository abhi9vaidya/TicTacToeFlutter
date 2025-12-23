import 'package:flutter/material.dart';
import 'dart:math' as math;
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
  late AnimationController _floatingController;
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

    _button1SlideAnimation =
        Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonsController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _button2SlideAnimation =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonsController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _buttonFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeIn),
    );

    // Floating animation for icons
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Start animations
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _buttonsController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonsController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Background particles
            ...List.generate(15, (index) => _buildParticle(index, size)),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide
                          ? size.width * 0.2
                          : AppSizes.paddingLarge,
                      vertical: AppSizes.paddingLarge,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Animated title
                        _buildAnimatedTitle(),

                        const SizedBox(height: 20),

                        // Subtitle
                        _buildSubtitle(),

                        const SizedBox(height: 50),

                        // Animated X and O icons
                        _buildGameIcons(),

                        const SizedBox(height: 60),

                        // Mode selection buttons
                        _buildModeButtons(isWide),

                        const SizedBox(height: 40),

                        // Credits
                        _buildCredits(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index, Size size) {
    final random = math.Random(index);
    final startX = random.nextDouble() * size.width;
    final startY = random.nextDouble() * size.height;
    final particleSize = 2.0 + random.nextDouble() * 4;
    final color = index % 2 == 0 ? AppColors.primary : AppColors.secondary;

    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset =
            math.sin(_floatingController.value * math.pi + index) * 20;
        return Positioned(
          left: startX,
          top: startY + offset,
          child: Container(
            width: particleSize,
            height: particleSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _titleAnimation.value,
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.primary,
                  ],
                  stops: [0, _titleGlowAnimation.value, 1],
                ).createShader(bounds),
                child: const Text(
                  'TIC TAC TOE',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 6,
                    shadows: [Shadow(color: AppColors.primary, blurRadius: 20)],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        return Opacity(
          opacity: _titleAnimation.value.clamp(0, 1),
          child: const Text(
            'The Classic Strategy Game',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameIcons() {
    return AnimatedBuilder(
      animation: Listenable.merge([_titleController, _floatingController]),
      builder: (context, child) {
        final floatOffset = math.sin(_floatingController.value * math.pi) * 8;
        return Opacity(
          opacity: _titleAnimation.value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, floatOffset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // X icon
                _buildXIcon(),
                const SizedBox(width: 30),
                // VS text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gridLine, width: 1),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                // O icon
                _buildOIcon(),
              ],
            ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.playerX.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.playerX.withOpacity(0.3),
            blurRadius: 25,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.playerO.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.playerO.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: OPainter(color: AppColors.playerO, progress: 1),
      ),
    );
  }

  Widget _buildModeButtons(bool isWide) {
    return Column(
      children: [
        // Two Player button
        SlideTransition(
          position: _button1SlideAnimation,
          child: FadeTransition(
            opacity: _buttonFadeAnimation,
            child: _buildModeButton(
              icon: Icons.people_alt_rounded,
              label: '2 PLAYERS',
              subtitle: 'Play with a friend',
              gradient: AppColors.primaryGradient,
              glowColor: AppColors.primary,
              onTap: () => _startGame(GameMode.twoPlayer),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // VS AI button
        SlideTransition(
          position: _button2SlideAnimation,
          child: FadeTransition(
            opacity: _buttonFadeAnimation,
            child: _buildModeButton(
              icon: Icons.smart_toy_rounded,
              label: 'VS AI',
              subtitle: 'Challenge the computer',
              gradient: AppColors.secondaryGradient,
              glowColor: AppColors.secondary,
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
    required String subtitle,
    required LinearGradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredits() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flutter_dash,
                color: AppColors.primary.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Made with Flutter',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
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

    final padding = size.width * 0.25;

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
    final radius = (size.width / 2) * 0.5;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(OPainter oldDelegate) => oldDelegate.progress != progress;
}
