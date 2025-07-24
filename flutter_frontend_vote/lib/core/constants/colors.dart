import 'package:flutter/material.dart';

class TColors {
  TColors._();

  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Web3 Primary Colors (from logo)
  static const Color primaryBlue = Color(0xFF00D4FF);
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color primaryIndigo = Color(0xFF4834D4);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F3F4);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [primaryPurple, primaryIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFFE2E8F0);

  // Accent Colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF4299E1);

  // Web3 Specific Colors
  static const Color blockchain = Color(0xFF00D4FF);
  static const Color crypto = Color(0xFF6C5CE7);
  static const Color nft = Color(0xFF4834D4);
  static const Color defi = Color(0xFF00CEC9);

  // Button Colors
  static const Color buttonPrimary = primaryBlue;
  static const Color buttonSecondary = primaryPurple;
  static const Color buttonDisabled = Color(0xFFE2E8F0);

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF4A5568);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x3D000000);
}
