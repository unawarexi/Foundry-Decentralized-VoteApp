import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const MiniStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Row(
      children: [
        Icon(icon, size: 13, color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
          ),
        ),
      ],
    );
  }
}
