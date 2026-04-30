import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'data_models.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'atomic_widgets.dart';
import 'scoreboard_row.dart';

class ScoreboardStrip extends StatelessWidget {
  final Animation<double> scoreboardFade;
  final Animation<Offset> scoreboardSlide;
  final Animation<double> pulseAnim;

  const ScoreboardStrip({
    super.key,
    required this.scoreboardFade,
    required this.scoreboardSlide,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: scoreboardFade,
      child: SlideTransition(
        position: scoreboardSlide,
        child: Container(
          padding: const EdgeInsets.all(TSizes.cardPadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2A1E), Color(0xFF12112A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(TSizes.radiusLg),
            border: Border.all(color: TColors.secondary.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: TColors.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AccentTag(label: 'ACCOUNTABILITY SCORE'),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: pulseAnim,
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.success.withOpacity(
                          0.08 + 0.05 * pulseAnim.value,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: TColors.success.withOpacity(
                            0.3 + 0.15 * pulseAnim.value,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: TColors.success,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: TColors.success,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...scoreboardCandidatesData.asMap().entries.map((e) {
                final i = e.key;
                final c = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ScoreboardRow(
                    candidate: c,
                    index: i,
                    entranceAnim: scoreboardFade,
                    pulseAnim: pulseAnim,
                  ),
                );
              }),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Response activity — last 7 days',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      color: isDark
                          ? TColors.textDarkTertiary
                          : TColors.textDarkTertiary.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Less',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      color: isDark
                          ? TColors.textDarkTertiary
                          : TColors.textDarkTertiary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 60,
                    height: 10,
                    child: CustomPaint(
                      painter: HeatmapPainter(
                        values: const [0.2, 0.8, 0.4, 1.0, 0.6, 0.3, 0.9],
                        activeColor: TColors.secondary,
                        inactiveColor: TColors.darkBorder,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'More',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      color: isDark
                          ? TColors.textDarkTertiary
                          : TColors.textDarkTertiary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
