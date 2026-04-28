import 'package:flutter/material.dart' hide AnimatedBuilder;
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/widgets/spinners.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'data_models.dart';

/// Global transparency feed tile with live/result badge.
class GlobalFeedTile extends StatelessWidget {
  final FeedItem item;
  final Animation<double> pulseAnim;

  const GlobalFeedTile({
    super.key,
    required this.item,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkCard : TColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? TColors.darkBorder : TColors.lightBorder),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Country flag placeholder
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: item.color.withOpacity(isDark ? 0.35 : 0.25)),
            ),
            child: Center(
              child: Text(
                item.flag,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: isDark ? TColors.textDarkTertiary : TColors.textLightSecondary),
                ),
              ],
            ),
          ),

          // Live indicator or result badge
          AnimatedBuilder(
            listenable: pulseAnim,
            builder: (_, __) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.isLive
                    ? TColors.success
                        .withOpacity(isDark ? (0.08 + 0.05 * pulseAnim.value) : (0.1 + 0.05 * pulseAnim.value))
                    : (isDark ? TColors.darkElevated : TColors.lightElevated),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: item.isLive
                        ? TColors.success
                            .withOpacity(0.3 + 0.15 * pulseAnim.value)
                        : (isDark ? TColors.darkBorder : TColors.lightBorder)),
              ),
              child: Text(
                item.isLive ? 'LIVE' : item.result,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: item.isLive
                        ? (isDark ? TColors.success : TColors.successDark)
                        : (isDark ? TColors.textDarkTertiary : TColors.textLightSecondary),
                    letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
