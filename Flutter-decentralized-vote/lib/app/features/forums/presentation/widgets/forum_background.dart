import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';

class ForumBackground extends StatelessWidget {
  final double scrollOffset;
  final Animation<double> shimmerPos;

  const ForumBackground({
    super.key,
    required this.scrollOffset,
    required this.shimmerPos,
  });

  @override
  Widget build(BuildContext context) {
    final p = (scrollOffset * 0.00015).clamp(0.0, 0.1);
    final isDark = THelperFunctions.isDarkMode(context);

    return Stack(
      children: [
        // Base Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + p, -1),
                end: const Alignment(1, 1),
                colors: isDark
                    ? const [
                        Color(0xFF080F0B),
                        TColors.darkBackground,
                        Color(0xFF0A0A12),
                      ]
                    : const [
                        Color(0xFFE8F0ED),
                        TColors.lightBackground,
                        Color(0xFFECECF4),
                      ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: Opacity(
            opacity: isDark ? 0.04 : 0.12,
            child: CustomPaint(painter: AuthGridPainter(color: TColors.secondary)),
          ),
        ),

        // Corner Decor
        Positioned(
          bottom: -70,
          left: -70,
          child: Opacity(
            opacity: isDark ? 0.05 : 0.18,
            child: CustomPaint(
              size: const Size(260, 260),
              painter: HexRingPainter(
                color: isDark ? TColors.secondary : TColors.primary.withOpacity(0.4),
              ),
            ),
          ),
        ),

        // Shimmer Effect
        AnimatedBuilder(
          animation: shimmerPos,
          builder: (context, _) => Positioned.fill(
            child: IgnorePointer(
              child: Transform.translate(
                offset: Offset(
                  MediaQuery.of(context).size.width *
                      (shimmerPos.value - 0.5) *
                      2,
                  0,
                ),
                child: Container(
                  width: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        TColors.secondary.withOpacity(isDark ? 0.05 : 0.1),
                        TColors.secondary.withOpacity(isDark ? 0.08 : 0.22),
                        TColors.secondary.withOpacity(isDark ? 0.05 : 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
