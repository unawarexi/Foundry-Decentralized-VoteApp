import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class ProfileStatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const ProfileStatChip({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkCard : TColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? TColors.darkBorder : TColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TColors.secondary, size: 15),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.white : TColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9.5,
              color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
              height: 1.4,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
