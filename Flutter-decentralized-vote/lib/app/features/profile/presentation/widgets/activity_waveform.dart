import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'accent_tag.dart';

class ActivityWaveform extends StatelessWidget {
  final Animation<double> contentFade;

  const ActivityWaveform({super.key, required this.contentFade});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: contentFade,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? TColors.darkCard : TColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? TColors.darkBorder : TColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AccentTag(label: 'CIVIC ACTIVITY'),
                const Spacer(),
                Text(
                  'Last 12 elections',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: CustomPaint(
                painter: WaveformPainter(
                  values: const [
                    0.6,
                    1.0,
                    0.8,
                    0.5,
                    1.0,
                    0.7,
                    0.9,
                    0.4,
                    1.0,
                    0.6,
                    0.8,
                    1.0,
                  ],
                  activeColor: TColors.secondary,
                  inactiveColor: isDark ? TColors.darkBorder : TColors.lightBorder,
                ),
                size: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Voted in 10 of 12 eligible elections',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                  ),
                ),
                const Spacer(),
                Text(
                  '83%',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: TColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
