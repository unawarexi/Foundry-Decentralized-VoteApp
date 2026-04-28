import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class AccentTag extends StatelessWidget {
  final String label;
  const AccentTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.secondary.withOpacity(isDark ? 0.5 : 0.4)),
        borderRadius: BorderRadius.circular(4),
        color: TColors.secondary.withOpacity(isDark ? 0.08 : 0.12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: TColors.secondary,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}
