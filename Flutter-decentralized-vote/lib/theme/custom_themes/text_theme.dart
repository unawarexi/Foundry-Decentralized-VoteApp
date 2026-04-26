import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';

class TTextTheme {
  TTextTheme._();

  // ──────────────── LIGHT TEXT THEME ────────────────
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: TColors.textLightPrimary,
    ),
    displayMedium: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: TColors.textLightPrimary,
    ),
    displaySmall: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w600,
      fontSize: 24,
      color: TColors.textLightPrimary,
    ),
    headlineLarge: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: TColors.textLightPrimary,
    ),
    headlineMedium: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: TColors.textLightPrimary,
    ),
    headlineSmall: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w500,
      fontSize: 18,
      color: TColors.textLightPrimary,
    ),
    titleLarge: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: TColors.textLightPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: TColors.textLightPrimary,
    ),
    titleSmall: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: TColors.textLightPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: TColors.textLightPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: TColors.textLightSecondary,
    ),
    bodySmall: GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: TColors.textLightSecondary,
    ),
    labelLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: TColors.textLightPrimary,
    ),
    labelMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 12,
      color: TColors.textLightSecondary,
    ),
    labelSmall: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 10,
      color: TColors.textLightTertiary,
    ),
  );

  // ──────────────── DARK TEXT THEME ────────────────
  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: TColors.textDarkPrimary,
    ),
    displayMedium: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: TColors.textDarkPrimary,
    ),
    displaySmall: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w600,
      fontSize: 24,
      color: TColors.textDarkPrimary,
    ),
    headlineLarge: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: TColors.textDarkPrimary,
    ),
    headlineMedium: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: TColors.textDarkPrimary,
    ),
    headlineSmall: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w500,
      fontSize: 18,
      color: TColors.textDarkPrimary,
    ),
    titleLarge: GoogleFonts.ibmPlexSerif(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: TColors.textDarkPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: TColors.textDarkPrimary,
    ),
    titleSmall: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: TColors.textDarkPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      color: TColors.textDarkPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: TColors.textDarkSecondary,
    ),
    bodySmall: GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: TColors.textDarkSecondary,
    ),
    labelLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: TColors.textDarkPrimary,
    ),
    labelMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 12,
      color: TColors.textDarkSecondary,
    ),
    labelSmall: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 10,
      color: TColors.textDarkTertiary,
    ),
  );
}
