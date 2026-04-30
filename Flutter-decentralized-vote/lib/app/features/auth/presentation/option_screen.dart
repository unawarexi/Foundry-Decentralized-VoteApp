import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/widgets/auth_widgets.dart';

class AuthOptionScreen extends StatelessWidget {
  const AuthOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: isDark
          ? TColors.darkBackground
          : TColors.lightBackground,
      body: Stack(
        children: [
          // --- Gold Patterned Background ---
          CustomPaint(
            size: size,
            painter: AuthGridPainter(
              color: TColors.secondary.withOpacity(isDark ? 0.10 : 0.13),
            ),
          ),
          // --- Fade Gradient Overlay ---
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        TColors.darkBackground.withOpacity(0.92),
                        Colors.transparent,
                        TColors.secondary.withOpacity(0.10),
                        Colors.transparent,
                        TColors.darkBackground.withOpacity(0.85),
                      ]
                    : [
                        TColors.lightBackground.withOpacity(0.96),
                        Colors.transparent,
                        TColors.secondary.withOpacity(0.10),
                        Colors.transparent,
                        TColors.lightBackground.withOpacity(0.90),
                      ],
                stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
              ),
            ),
          ),
          // --- Large Hex Ring Accent ---
          Positioned(
            top: -100,
            right: -100,
            child: Opacity(
              opacity: 0.10,
              child: CustomPaint(
                size: const Size(400, 400),
                painter: HexRingPainter(),
              ),
            ),
          ),
          // --- Swoosh Accent ---
          Positioned(
            bottom: -60,
            left: -60,
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                size: const Size(220, 220),
                painter: SSwooshPainter(
                  colors: [TColors.secondary, TColors.primary],
                  isDark: isDark,
                ),
              ),
            ),
          ),
          // --- Main Content ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CustomPaint(painter: MiniLogoPainter()),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'VOTESECURE',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSerif',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? TColors.white : TColors.primary,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const AuthAccentTag(label: 'SELECT ACCOUNT TYPE'),
                  const SizedBox(height: 12),
                  Text(
                    'How will you\nparticipate?',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSerif',
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: isDark ? TColors.white : TColors.primary,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(width: 40, height: 2, color: TColors.secondary),
                  const SizedBox(height: 14),
                  Text(
                    'Choose your role to begin. Each path is secured, transparent, and tailored for your participation.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: isDark
                          ? TColors.textDarkSecondary
                          : TColors.textLightSecondary,
                      height: 1.65,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Option Cards
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _OptionCard(
                            title: 'Continue as Candidate',
                            description:
                                'Run for leadership — Presidential, Governor, CEO, or any elected position.',
                            icon: Icons.how_to_reg_rounded,
                            isDark: isDark,
                            highlight: true,
                            isLast: false,
                            onTap: () => context.go('/candidate-signup'),
                          ),
                          _OptionCard(
                            title: 'Continue as Voter',
                            description:
                                'Cast your vote — one citizen, one immutable, verifiable ballot.',
                            icon: Icons.person_pin_rounded,
                            isDark: isDark,
                            highlight: false,
                            isLast: true,
                            onTap: () => context.go('/signup'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Already have an account? Sign In',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: isDark
                              ? TColors.textDarkTertiary
                              : TColors.textLightTertiary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isDark;
  final bool highlight;
  final bool isLast;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isDark,
    required this.highlight,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Gold for highlighted, Silver/Grey for the other
    final Color primaryColor = highlight
        ? TColors.secondary
        : (isDark ? const Color(0xFFB0BEC5) : const Color(0xFF78909C));

    final Color bgColor = highlight
        ? TColors.secondary.withValues(alpha: 0.1)
        : (isDark
              ? Colors.grey[800]!.withValues(alpha: 0.3)
              : Colors.grey[200]!);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator (Node + Line)
          Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDark ? TColors.darkBorder : TColors.lightBorder,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: highlight
                      ? TColors.secondary.withValues(alpha: 0.3)
                      : (isDark
                            ? const Color(0xFFE0E0E0).withValues(alpha: 0.15)
                            : const Color(0xFF9E9E9E).withValues(alpha: 0.2)),
                  highlightColor: highlight
                      ? TColors.secondary.withValues(alpha: 0.1)
                      : (isDark
                            ? const Color(0xFFE0E0E0).withValues(alpha: 0.05)
                            : const Color(0xFF9E9E9E).withValues(alpha: 0.1)),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? TColors.darkCard : TColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: highlight
                            ? TColors.secondary.withValues(alpha: 0.3)
                            : (isDark
                                  ? TColors.darkBorder
                                  : TColors.lightBorder),
                      ),
                      boxShadow: highlight
                          ? [
                              BoxShadow(
                                color: TColors.secondary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSerif',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? TColors.white : TColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: isDark
                                ? TColors.textDarkSecondary
                                : TColors.textLightSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Select Role',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: primaryColor,
                              size: 14,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
