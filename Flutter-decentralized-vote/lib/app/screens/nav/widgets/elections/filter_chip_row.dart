import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class FilterChipRow extends StatelessWidget {
  final List<String> filterLabels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Animation<double> filterFade;

  const FilterChipRow({
    super.key,
    required this.filterLabels,
    required this.selectedIndex,
    required this.onChanged,
    required this.filterFade,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: filterFade,
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filterLabels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final selected = selectedIndex == i;
            return GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? TColors.primary.withOpacity(isDark ? 0.55 : 1.0)
                      : (isDark ? TColors.darkCard : TColors.lightCard),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? TColors.secondary.withOpacity(0.55)
                        : (isDark ? TColors.darkBorder : TColors.lightBorder),
                    width: selected ? 1.2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      filterLabels[i],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? TColors.secondary
                            : (isDark
                                  ? TColors.textDarkTertiary
                                  : TColors.textLightTertiary),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: selected ? 18 : 0,
                      height: 2,
                      decoration: BoxDecoration(
                        color: TColors.secondary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
