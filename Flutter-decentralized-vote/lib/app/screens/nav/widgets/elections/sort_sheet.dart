import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class SortSheet extends StatelessWidget {
  const SortSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.darkSurface : TColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: isDark ? TColors.darkBorder : TColors.lightBorder),
          left: BorderSide(color: isDark ? TColors.darkBorder : TColors.lightBorder),
          right: BorderSide(color: isDark ? TColors.darkBorder : TColors.lightBorder),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? TColors.darkBorder : TColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sort & Filter',
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.white : TColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Container(width: 32, height: 2, color: TColors.secondary),
          const SizedBox(height: 20),
          ...[
            ('Most Participants', Icons.people_outline_rounded),
            ('Closing Soon', Icons.timer_outlined),
            ('Recently Added', Icons.new_releases_outlined),
            ('Alphabetical', Icons.sort_by_alpha_rounded),
            ('Near My Region', Icons.location_on_outlined),
          ].asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: (isDark ? TColors.darkBorder : TColors.lightBorder)
                          .withOpacity(i < 4 ? 1 : 0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.$2,
                      color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                      size: 18,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      item.$1,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: isDark ? TColors.textDarkSecondary : TColors.textLightSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? TColors.darkBorder : TColors.lightBorder,
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
