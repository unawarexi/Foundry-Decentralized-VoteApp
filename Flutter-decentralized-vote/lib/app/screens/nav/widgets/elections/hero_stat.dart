import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const HeroStat({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? TColors.white : TColors.secondary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            color: isDark
                ? TColors.textDarkTertiary
                : TColors.textLightTertiary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class HeroStatDivider extends StatelessWidget {
  const HeroStatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark ? TColors.darkBorder : TColors.lightBorder,
    );
  }
}
