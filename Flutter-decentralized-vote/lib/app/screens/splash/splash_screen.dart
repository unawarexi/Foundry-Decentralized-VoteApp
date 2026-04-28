import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/splash/splash_components.dart';
import 'package:go_router/go_router.dart';

/// VoteSecure Splash Screen
/// Tone: "Modern infrastructure with institutional weight"
/// Animation: Deliberate, authoritative — not playful
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final SplashOrchestrator _orchestrator;

  @override
  void initState() {
    super.initState();
    _orchestrator = SplashOrchestrator(
      vsync: this,
      onComplete: () {
        if (mounted) {
          context.go('/onboarding');
        }
      },
    );
    _orchestrator.startSequence();
  }

  @override
  void dispose() {
    _orchestrator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
    final bgColor = isDark ? TColors.darkBackground : TColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedBuilder(
        animation: _orchestrator.combinedListenable,
        builder: (context, _) {
          return FadeTransition(
            opacity: _orchestrator.exitOpacity,
            child: ScaleTransition(
              scale: _orchestrator.exitScale,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildBackground(),
                  _buildGrid(),
                  _buildRadialGlow(),
                  _buildContent(),
                  _buildShimmer(),
                  _buildBottomBar(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    final isDark = THelperFunctions.isDarkMode(context);
    final bgColor = isDark ? TColors.darkBackground : TColors.lightBackground;

    return AnimatedBuilder(
      animation: _orchestrator.bgAnimation,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(
                bgColor,
                const Color(0xFF0B3D2E),
                _orchestrator.bgAnimation.value,
              )!,
              Color.lerp(
                bgColor,
                isDark ? const Color(0xFF0A0A14) : const Color(0xFFE8E8E8),
                _orchestrator.bgAnimation.value,
              )!,
              Color.lerp(
                bgColor,
                isDark
                    ? const Color(0xFF1A1A40).withValues(alpha: 0.8)
                    : const Color(0xFFC0C0C0).withValues(alpha: 0.8),
                _orchestrator.bgAnimation.value,
              )!,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final isDark = THelperFunctions.isDarkMode(context);
    final gridColor = isDark
        ? TColors.secondary.withValues(alpha: 0.4)
        : TColors.secondary.withValues(alpha: 0.2);

    return Opacity(
      opacity: _orchestrator.gridOpacity.value,
      child: CustomPaint(painter: GridPainter(color: gridColor)),
    );
  }

  Widget _buildRadialGlow() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              TColors.primary.withValues(alpha: 
                0.3 * _orchestrator.logoOpacity.value,
              ),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final isDark = THelperFunctions.isDarkMode(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo mark
        Stack(
          alignment: Alignment.center,
          children: [
            // Expanding gold ring
            Transform.scale(
              scale: _orchestrator.ringScale.value,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: TColors.secondary.withValues(alpha: 
                      _orchestrator.ringOpacity.value,
                    ),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Logo icon
            Transform.rotate(
              angle: _orchestrator.logoRotate.value,
              child: Transform.scale(
                scale: _orchestrator.logoScale.value,
                child: Opacity(
                  opacity: _orchestrator.logoOpacity.value,
                  child: const VoteSecureLogo(size: 88),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // App name
        FadeTransition(
          opacity: _orchestrator.appNameOpacity,
          child: SlideTransition(
            position: _orchestrator.appNameSlide,
            child: Column(
              children: [
                Text(
                  'VOTESECURE',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSerif',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? TColors.white : TColors.primary,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 12),

                // Gold divider line
                AnimatedBuilder(
                  animation: _orchestrator.dividerWidth,
                  builder: (_, __) => Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 120 * _orchestrator.dividerWidth.value,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            TColors.secondary,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                FadeTransition(
                  opacity: _orchestrator.taglineOpacity,
                  child: SlideTransition(
                    position: _orchestrator.taglineSlide,
                    child: Text(
                      'Decentralized Electoral Infrastructure',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? TColors.textDarkSecondary
                            : TColors.textLightSecondary,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return AnimatedBuilder(
      animation: _orchestrator.shimmerPosition,
      builder: (_, __) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Transform.translate(
              offset: Offset(
                MediaQuery.of(context).size.width *
                    (_orchestrator.shimmerPosition.value - 0.5) *
                    2,
                0,
              ),
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      TColors.secondary.withValues(alpha: 0.06),
                      TColors.secondary.withValues(alpha: 0.12),
                      TColors.secondary.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final isDark = THelperFunctions.isDarkMode(context);
    return Positioned(
      bottom: 48,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _orchestrator.taglineOpacity,
        child: Column(
          children: [
            // Loading dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _orchestrator.shimmerController,
                  builder: (_, __) {
                    final delay = i * 0.25;
                    final progress =
                        ((_orchestrator.shimmerController.value - delay).clamp(
                                  0.0,
                                  0.4,
                                ) /
                                0.4)
                            .clamp(0.0, 1.0);
                    return Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TColors.secondary.withValues(alpha: 
                          0.2 + 0.6 * progress,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(
              'Secured by Zero-Knowledge Proof',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
