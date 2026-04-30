import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class VerifyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final bool active;
  final Animation<double> pulseAnim;

  const VerifyChip({
    super.key,
    required this.icon,
    required this.label,
    required this.status,
    required this.active,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: active 
              ? TColors.success.withOpacity(0.06) 
              : (isDark ? TColors.darkCard : TColors.lightCard),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? TColors.success.withOpacity(0.25 + 0.12 * pulseAnim.value)
                : (isDark ? TColors.darkBorder : TColors.lightBorder),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 15,
              color: active 
                  ? TColors.success 
                  : (isDark ? TColors.textDarkTertiary : TColors.textLightTertiary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 8.5,
                color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: active ? TColors.success : TColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
