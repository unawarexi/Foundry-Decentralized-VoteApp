import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/splash/splash_components.dart';

class NavPlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const NavPlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? TColors.darkBackground : TColors.lightBackground,
      body: Stack(
        children: [
          // Institutional Grid Background
          Opacity(
            opacity: 0.03,
            child: CustomPaint(
              size: size,
              painter: GridPainter(
                color: isDark ? TColors.white : TColors.primary,
                spacing: 40.0,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Institutional Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: TColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: TColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSerif',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: TColors.primary,
                            ),
                          ),
                          Text(
                            'VOTESECURE CORE MODULE',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: isDark 
                                ? TColors.textDarkTertiary 
                                : TColors.textLightTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Authority Messaging
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 64,
                          color: isDark 
                            ? TColors.darkBorder 
                            : TColors.lightBorder,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSerif',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDark 
                              ? TColors.textDarkSecondary 
                              : TColors.textLightSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, 
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: TColors.secondary.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'PENDING AUTHORIZATION',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: TColors.secondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
