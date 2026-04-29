import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'accent_tag.dart';
import 'data_models.dart';

/// Forum question tile with unanswered countdown timer badge.
class ForumQuestionTile extends StatelessWidget {
  final ForumData data;
  const ForumQuestionTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkCard : TColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: data.isUnanswered
              ? TColors.warning.withOpacity(0.3)
              : (isDark ? TColors.darkBorder : TColors.lightBorder),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: AccentTag(label: data.candidate)),
              const SizedBox(width: 8),
              // Timer badge — if unanswered, shows 24hr countdown
              if (data.isUnanswered)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: TColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border:
                        Border.all(color: TColors.warning.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 10, color: TColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        data.timer,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: TColors.warning,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.question,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
                height: 1.5),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded,
                        size: 13, color: TColors.secondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${data.upvotes} upvotes',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: TColors.secondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.comment_outlined,
                        size: 13, color: isDark ? TColors.textDarkTertiary : TColors.textLightSecondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${data.answers} answers',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: isDark ? TColors.textDarkTertiary : TColors.textLightSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.timePosted,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: isDark ? TColors.textDarkTertiary : TColors.textLightSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
