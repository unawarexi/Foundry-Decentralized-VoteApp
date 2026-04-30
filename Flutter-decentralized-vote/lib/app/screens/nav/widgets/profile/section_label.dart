import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'accent_tag.dart';

class SectionLabel extends StatelessWidget {
  final String tag;
  final String title;
  final Animation<double> contentFade;

  const SectionLabel({
    super.key,
    required this.tag,
    required this.title,
    required this.contentFade,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: contentFade,
      child: Row(
        children: [
          AccentTag(label: tag),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.white : TColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
