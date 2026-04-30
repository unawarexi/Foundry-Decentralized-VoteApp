import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class AvatarChip extends StatelessWidget {
  const AvatarChip({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF0B3D2E), const Color(0xFF1A1A40)]
              : [TColors.primary, TColors.secondaryAlt.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: TColors.secondary.withOpacity(isDark ? 0.45 : 0.3)),
      ),
      child: const Center(
        child: Text(
          'AO',
          style: TextStyle(
            fontFamily: 'IBMPlexSerif',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: TColors.secondary,
          ),
        ),
      ),
    );
  }
}
