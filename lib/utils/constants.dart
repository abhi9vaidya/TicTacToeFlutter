import 'package:flutter/material.dart';

/// App color palette - Neon cyberpunk theme
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF00F5FF);      // Cyan neon
  static const Color secondary = Color(0xFFFF00E5);    // Magenta neon
  static const Color accent = Color(0xFFFFE500);       // Yellow neon
  
  // Background colors
  static const Color background = Color(0xFF0A0E17);   // Deep dark blue
  static const Color surface = Color(0xFF151B28);      // Card surface
  static const Color surfaceLight = Color(0xFF1E2535); // Lighter surface
  
  // Game colors
  static const Color playerX = Color(0xFF00F5FF);      // Cyan for X
  static const Color playerO = Color(0xFFFF00E5);      // Magenta for O
  static const Color winLine = Color(0xFFFFE500);      // Yellow win line
  static const Color gridLine = Color(0xFF2A3344);     // Grid lines
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8892A6);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00F5FF), Color(0xFF00B8D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF00E5), Color(0xFFB800A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E17), Color(0xFF151B28)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Animation durations
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration xDraw = Duration(milliseconds: 400);
  static const Duration oDraw = Duration(milliseconds: 350);
  static const Duration winLine = Duration(milliseconds: 600);
  static const Duration boardReset = Duration(milliseconds: 400);
}

/// App sizing constants
class AppSizes {
  static const double borderRadius = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double padding = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;
  
  static const double tileSize = 90.0;
  static const double gridSpacing = 12.0;
  static const double strokeWidth = 4.0;
  static const double strokeWidthThin = 2.0;
}

/// App text styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  );
  
  static const TextStyle score = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
}

/// Game enums
enum Player { none, x, o }

enum GameMode { twoPlayer, vsAI }

enum Difficulty { easy, medium, hard }
