import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';


class TTextTheme {
  TTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: TColors.textPrimary,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
      color: TColors.textPrimary,
    ),
    titleLarge: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: TColors.textPrimary,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: TColors.textSecondary,
    ),
    bodyLarge: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: TColors.textPrimary,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: TColors.textSecondary,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: TColors.textSecondary,
    ),
    labelLarge: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: TColors.textPrimary,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: TColors.textSecondary,
    ),
    labelSmall: const TextStyle().copyWith(
      fontSize: 10.0,
      fontWeight: FontWeight.w300,
      color: TColors.textSecondary,
    ),
  );

  ///------------ CUSTOMIZABLE DARK TEXT THEME -------------- ///

  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: TColors.textDark,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: TColors.textDark,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
      color: TColors.textDark,
    ),
    titleLarge: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: TColors.textDark,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: TColors.textDark,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: TColors.textDarkSecondary,
    ),
    bodyLarge: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: TColors.textDark,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: TColors.textDarkSecondary,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: TColors.textDarkSecondary,
    ),
    labelLarge: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: TColors.textDark,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: TColors.textDarkSecondary,
    ),
    labelSmall: const TextStyle().copyWith(
      fontSize: 10.0,
      fontWeight: FontWeight.w300,
      color: TColors.textDarkSecondary,
    ),
  );

  // Additional themed text styles for Web3 specific use cases
  static TextStyle accentText = const TextStyle().copyWith(
    color: TColors.primaryBlue,
    fontWeight: FontWeight.w600,
  );

  static TextStyle gradientText = const TextStyle().copyWith(
    fontWeight: FontWeight.bold,
    // Note: For gradient text, you'll need to use a ShaderMask widget
    // with TColors.primaryGradient
  );

  static TextStyle cryptoText = const TextStyle().copyWith(
    color: TColors.crypto,
    fontWeight: FontWeight.w500,
  );

  static TextStyle blockchainText = const TextStyle().copyWith(
    color: TColors.blockchain,
    fontWeight: FontWeight.w500,
  );

  static TextStyle errorText = const TextStyle().copyWith(
    color: TColors.error,
    fontWeight: FontWeight.w500,
  );

  static TextStyle successText = const TextStyle().copyWith(
    color: TColors.success,
    fontWeight: FontWeight.w500,
  );

  static TextStyle warningText = const TextStyle().copyWith(
    color: TColors.warning,
    fontWeight: FontWeight.w500,
  );
}
