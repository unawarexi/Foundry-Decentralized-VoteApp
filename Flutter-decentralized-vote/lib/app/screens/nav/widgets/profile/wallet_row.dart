import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class WalletRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool mono;

  const WalletRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Row(
      children: [
        Icon(
          icon, 
          size: 15, 
          color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: isDark ? TColors.textDarkSecondary : TColors.textLightSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: mono ? 'IBMPlexMono' : 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
            letterSpacing: mono ? 0.8 : 0,
          ),
        ),
      ],
    );
  }
}
