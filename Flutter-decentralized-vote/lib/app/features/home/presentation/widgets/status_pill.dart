import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const StatusPill({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? TColors.success.withOpacity(0.1)
            : (isDark ? TColors.darkElevated : TColors.lightElevated),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: active
                ? TColors.success.withOpacity(0.35)
                : (isDark ? TColors.darkBorder : TColors.lightBorder)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 11,
              color: active ? TColors.success : (isDark ? TColors.textDarkTertiary : TColors.textLightTertiary)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: active ? TColors.success : (isDark ? TColors.textDarkTertiary : TColors.textLightTertiary),
                letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }
}
