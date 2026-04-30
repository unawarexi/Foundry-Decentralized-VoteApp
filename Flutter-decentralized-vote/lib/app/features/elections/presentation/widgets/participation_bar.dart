import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class ParticipationBar extends StatelessWidget {
  final int percent;
  final Animation<double> entranceAnim;
  const ParticipationBar({
    super.key,
    required this.percent,
    required this.entranceAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PARTICIPATION',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: TColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: AnimatedBuilder(
            animation: entranceAnim,
            builder: (_, __) => LinearProgressIndicator(
              value: (percent / 100) * entranceAnim.value,
              backgroundColor: isDark ? TColors.darkBorder : TColors.lightBorder,
              valueColor: AlwaysStoppedAnimation(TColors.secondary),
              minHeight: 5,
            ),
          ),
        ),
      ],
    );
  }
}
