import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class CountdownBlock extends StatelessWidget {
  final String value;
  final String label;
  const CountdownBlock({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Container(
          width: 56,
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? TColors.darkElevated : TColors.lightElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? TColors.darkBorder : TColors.lightBorder,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween(
                  begin: const Offset(0, -0.4),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                value,
                key: ValueKey(value),
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? TColors.white : TColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 8.5,
            color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class CountdownSeparator extends StatelessWidget {
  const CountdownSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 16),
      child: Text(
        ':',
        style: TextStyle(
          fontFamily: 'IBMPlexMono',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: TColors.secondary.withOpacity(0.6),
        ),
      ),
    );
  }
}
