import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'accent_tag.dart';
import 'data_models.dart';

/// Vertical list tile for upcoming (scheduled) elections.
class UpcomingElectionTile extends StatelessWidget {
  final int index;
  final Animation<double> entranceAnim;

  const UpcomingElectionTile({
    super.key,
    required this.index,
    required this.entranceAnim,
  });

  @override
  Widget build(BuildContext context) {
    final d = upcomingElections[index];
    final isDark = THelperFunctions.isDarkMode(context);
    // Per-tile FadeTransition with staggered delay
    return FadeTransition(
      opacity: entranceAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.darkCard : TColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? TColors.darkBorder : TColors.lightBorder,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Date block
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TColors.secondary.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    d.month,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8,
                      color: TColors.secondary,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    d.day,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSerif',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TColors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.title,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSerif',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TColors.white : TColors.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    d.region,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: isDark
                          ? TColors.textDarkTertiary
                          : TColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Level tag
            AccentTag(label: d.level),
          ],
        ),
      ),
    );
  }
}
