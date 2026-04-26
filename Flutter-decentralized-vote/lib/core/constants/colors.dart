import 'package:flutter/material.dart';

/// VoteSecure institutional color palette.
/// Designed for "Modern infrastructure with institutional weight".
/// Avoids the flashy "tech startup" look in favor of credibility and authority.
class TColors {
  TColors._();

  // ──────────────── BRAND CORE TOKENS ────────────────
  // Primary (Authority - Deep Forest Green)
  static const Color primary = Color(0xFF0B3D2E); 
  static const Color primaryDark = Color(0xFF0F5132); 

  // Secondary (Web3/AI Signal - Muted Gold)
  static const Color secondary = Color(0xFFC6A75E);
  // Alternative Secondary (Deep Indigo for tech/compute signals)
  static const Color secondaryAlt = Color(0xFF1A1A40);

  // Accent (Interaction/Action - Burnt Orange)
  static const Color accent = Color(0xFFD96C2D);

  // ──────────────── LIGHT MODE ────────────────
  static const Color lightBackground = Color(0xFFF8F7F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF0F0F0);
  static const Color lightBorder = Color(0xFFE0DED9);
  static const Color lightHover = Color(0xFFE5E2DC);
  static const Color lightMuted = Color(0xFFD6D6D6);

  // ──────────────── DARK MODE ────────────────
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCard = Color(0xFF18181B);
  static const Color darkElevated = Color(0xFF1E1E24);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkHover = Color(0xFF2E2E35);
  static const Color darkMuted = Color(0xFF5A5A5A);

  // ──────────────── TEXT ────────────────
  static const Color textLightPrimary = Color(0xFF1C1C1C); // Charcoal
  static const Color textLightSecondary = Color(0xFF5A5A5A);
  static const Color textLightTertiary = Color(0xFF888888);

  static const Color textDarkPrimary = Color(0xFFF5F5F5); // Off-White
  static const Color textDarkSecondary = Color(0xFFB0B0B0);
  static const Color textDarkTertiary = Color(0xFF71717A);

  // ──────────────── SEMANTIC ────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF064E3B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF78350F);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E3A5F);

  // ──────────────── PURE ────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ──────────────── GRADIENTS ────────────────
  /// Subtle gradient giving depth to primary authoritative components.
  static const LinearGradient institutionalGradient = LinearGradient(
    colors: [Color(0xFF0B3D2E), Color(0xFF1A1A40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A0A), Color(0xFF121212)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ──────────────── LEGACY ALIASES (For backward compatibility during migration) ────────────────
  static const Color textPrimary = textLightPrimary;
  static const Color textLight = textLightPrimary;
  static const Color textSecondary = textLightSecondary;
  static const Color textTertiary = textLightTertiary;
  static const Color textDark = textDarkPrimary;

  static const Color primaryBlue = secondaryAlt; // Re-mapped
  static const Color primaryPurple = secondaryAlt; // Re-mapped
  static const Color primaryIndigo = secondaryAlt; // Re-mapped
  static const Color primarySurface = lightElevated;
  static const Color primaryMuted = lightMuted;
  static const Color indigo700 = secondaryAlt;
  static const Color indigo900 = secondaryAlt;
  static const Color indigo400 = secondaryAlt;

  static const Color blockchain = secondary; // Gold
  static const Color defi = secondary;
  static const Color nft = secondary;
  static const Color zkProof = secondaryAlt;
  static const Color consensus = success;
  static const Color gasToken = accent;

  static const Color voteActive = primary;
  static const Color votePending = warning;
  static const Color voteClosed = error;
  static const Color voteVerified = secondary;
  static const Color candidateCard = darkCard;
  static const Color electionBanner = primary;

  static const Color borderLight = lightBorder;
  static const Color borderDark = darkBorder;

  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  
  static const Color lightBg = lightBackground;
  static const Color darkBg = darkBackground;

  // Interaction legacy mappings
  static const Color micOn = success;
  static const Color micOff = error;
  static const Color cameraOn = success;
  static const Color cameraOff = error;
  static const Color screenShare = secondaryAlt;
  static const Color handRaised = warning;
  static const Color callEnd = error;
  static const Color callEndHover = errorDark;
  static const Color participantTile = darkElevated;
  static const Color participantTileLight = lightElevated;

  static const Color chatBubbleSent = primary;
  static const Color chatBubbleReceived = darkElevated;
  static const Color chatBubbleReceivedLight = lightElevated;

  static const LinearGradient primaryGradient = institutionalGradient;
  static const LinearGradient accentGradient = institutionalGradient;
  static const LinearGradient blockchainGradient = institutionalGradient;
  static const LinearGradient voteGradient = institutionalGradient;
}
