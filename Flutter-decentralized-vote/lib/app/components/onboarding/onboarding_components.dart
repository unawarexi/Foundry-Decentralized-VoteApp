import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/onboarding/onboarding_illustrations.dart';

// ──────────────────────────────────────────────────────────────
// Accent tag pill
// ──────────────────────────────────────────────────────────────
class AccentTag extends StatelessWidget {
  final String label;
  const AccentTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.secondary.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: TColors.secondary.withOpacity(0.08),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: TColors.secondary,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Slide data model
// ──────────────────────────────────────────────────────────────
enum SlideVisual { identity, regionLock, blockchain, transparency, governance }

class OnboardSlide {
  final String tag;
  final String headline;
  final String body;
  final SlideVisual visual;
  final String accentLabel;

  const OnboardSlide({
    required this.tag,
    required this.headline,
    required this.body,
    required this.visual,
    required this.accentLabel,
  });
}

// ──────────────────────────────────────────────────────────────
// Slide illustrations — custom-painted for each slide
// ──────────────────────────────────────────────────────────────
class SlideIllustration extends StatelessWidget {
  final SlideVisual visual;
  final int index;
  final double animationValue;

  const SlideIllustration({
    super.key,
    required this.visual,
    required this.index,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? TColors.darkSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: TColors.darkBorder) : null,
        ),
        child: CustomPaint(
          painter: _getIllustrationPainter(visual, animationValue, isDark),
          child: Container(),
        ),
      ),
    );
  }

  CustomPainter _getIllustrationPainter(
    SlideVisual v,
    double animValue,
    bool isDark,
  ) {
    switch (v) {
      case SlideVisual.identity:
        return IdentityIllustration(progress: animValue, isDark: isDark);
      case SlideVisual.regionLock:
        return RegionLockIllustration(progress: animValue, isDark: isDark);
      case SlideVisual.blockchain:
        return BlockchainIllustration(progress: animValue, isDark: isDark);
      case SlideVisual.transparency:
        return TransparencyIllustration(progress: animValue, isDark: isDark);
      case SlideVisual.governance:
        return GovernanceIllustration(progress: animValue, isDark: isDark);
    }
  }
}

// ──────────────────────────────────────────────────────────────
// Mini logo for top bar
// ──────────────────────────────────────────────────────────────
class MiniLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final hexPaint = Paint()
      ..color = TColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = c.dx + r * 0.9 * math.cos(angle);
      final y = c.dy + r * 0.9 * math.sin(angle);
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, hexPaint);

    canvas.drawCircle(c, r * 0.55, Paint()..color = TColors.primary);

    final checkPaint = Paint()
      ..color = TColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(c.dx - r * 0.22, c.dy);
    checkPath.lineTo(c.dx - r * 0.04, c.dy + r * 0.18);
    checkPath.lineTo(c.dx + r * 0.24, c.dy - r * 0.2);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
