import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'data_models.dart';
import 'accent_tag.dart';

class VoteHistoryTile extends StatelessWidget {
  final VoteRecord record;
  final int index;
  final Animation<double> contentAnim;

  const VoteHistoryTile({
    super.key,
    required this.record,
    required this.index,
    required this.contentAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final stagger = CurvedAnimation(
      parent: contentAnim,
      curve: Interval(
        (index * 0.05).clamp(0.0, 0.6),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: stagger,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? TColors.darkCard : TColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? TColors.darkBorder : TColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Date block — Restored institutional green background as requested
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TColors.secondary.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    record.month,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: TColors.secondary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    record.day,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSerif',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TColors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.election,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSerif',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TColors.white : TColors.textLightPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    record.region,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: isDark
                          ? TColors.textDarkTertiary
                          : TColors.textLightTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: const [
                    Icon(Icons.link_rounded, size: 11, color: TColors.success),
                    SizedBox(width: 4),
                    const Text(
                      'On-chain',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: TColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AccentTag(label: record.level),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
