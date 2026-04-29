import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'painters.dart';

class ForumEmptyState extends StatelessWidget {
  final Animation<double> listAnim;

  const ForumEmptyState({super.key, required this.listAnim});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: listAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.pagePadding,
          vertical: 60,
        ),
        child: Column(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(painter: HexRingPainter()),
            ),
            const SizedBox(height: 20),
            Text(
              'No questions found',
              style: TextStyle(
                fontFamily: 'IBMPlexSerif',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? TColors.white : TColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to ask a question\nand hold candidates accountable.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
