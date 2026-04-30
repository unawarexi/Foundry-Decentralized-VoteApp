import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'accent_tag.dart';

class SectionLabel extends StatelessWidget {
  final String tag;
  final String title;
  final String trailing;

  const SectionLabel({
    super.key,
    required this.tag,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (tag.isNotEmpty) ...[
          AccentTag(label: tag),
          const SizedBox(width: 10),
        ],
        if (title.isNotEmpty)
          Text(
            title,
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.white : TColors.primary,
            ),
          ),
        const Spacer(),
        if (trailing.isNotEmpty)
          Text(
            trailing,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: TColors.secondary,
            ),
          ),
      ],
    );
  }
}
