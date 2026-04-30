import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/features/home/presentation/widgets/accent_tag.dart';
import 'dart:math' as math;

class SearchField extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.ctrl,
    required this.focus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: (THelperFunctions.isDarkMode(context)
            ? TColors.darkCard
            : TColors.lightCard),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TColors.secondary.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: TColors.secondary.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            color: TColors.secondary.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: ctrl,
              focusNode: focus,
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: (THelperFunctions.isDarkMode(context)
                    ? TColors.textDarkPrimary
                    : TColors.textLightPrimary),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: 'Search candidates, parties, regions…',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: (THelperFunctions.isDarkMode(context)
                      ? TColors.textDarkTertiary
                      : TColors.textLightTertiary),
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SortSheet extends StatelessWidget {
  final int currentSort;
  final void Function(int) onSelect;

  const SortSheet({
    super.key,
    required this.currentSort,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      ('Popularity', Icons.trending_up_rounded),
      ('A–Z Name', Icons.sort_by_alpha_rounded),
      ('By Region', Icons.location_on_outlined),
      ('By Party', Icons.groups_outlined),
    ];
    return Container(
      decoration: BoxDecoration(
        color: (THelperFunctions.isDarkMode(context)
            ? TColors.darkSurface
            : TColors.lightSurface),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: (THelperFunctions.isDarkMode(context)
                ? TColors.darkBorder
                : TColors.lightBorder),
          ),
          left: BorderSide(
            color: (THelperFunctions.isDarkMode(context)
                ? TColors.darkBorder
                : TColors.lightBorder),
          ),
          right: BorderSide(
            color: (THelperFunctions.isDarkMode(context)
                ? TColors.darkBorder
                : TColors.lightBorder),
          ),
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
                color: (THelperFunctions.isDarkMode(context)
                    ? TColors.darkBorder
                    : TColors.lightBorder),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sort Candidates',
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: (THelperFunctions.isDarkMode(context)
                  ? TColors.white
                  : TColors.black),
            ),
          ),
          const SizedBox(height: 6),
          Container(width: 32, height: 2, color: TColors.secondary),
          const SizedBox(height: 20),
          ...options.asMap().entries.map((e) {
            final selected = currentSort == e.key;
            return GestureDetector(
              onTap: () => onSelect(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          (THelperFunctions.isDarkMode(context)
                                  ? TColors.darkBorder
                                  : TColors.lightBorder)
                              .withOpacity(e.key < 3 ? 1 : 0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      e.value.$2,
                      color: selected
                          ? TColors.secondary
                          : (THelperFunctions.isDarkMode(context)
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary),
                      size: 18,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      e.value.$1,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: selected
                            ? TColors.secondary
                            : (THelperFunctions.isDarkMode(context)
                                  ? TColors.textDarkSecondary
                                  : TColors.textLightSecondary),
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    if (selected)
                      const Icon(
                        Icons.check_rounded,
                        color: TColors.secondary,
                        size: 16,
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

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  const StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(StickyHeaderDelegate old) =>
      maxHeight != old.maxHeight ||
      minHeight != old.minHeight ||
      child != old.child;
}

class CandidatesHeader extends StatelessWidget {
  final int count;
  final Animation<double> listFade;
  final String currentSortLabel;
  final VoidCallback onTapSort;

  const CandidatesHeader({
    super.key,
    required this.count,
    required this.listFade,
    required this.currentSortLabel,
    required this.onTapSort,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: listFade,
      child: Row(
        children: [
          const AccentTag(label: 'ALL CANDIDATES'),
          const SizedBox(width: 10),
          Text(
            '$count registered',
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: (THelperFunctions.isDarkMode(context)
                  ? TColors.white
                  : TColors.black),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTapSort,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (THelperFunctions.isDarkMode(context)
                    ? TColors.darkCard
                    : TColors.lightCard),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (THelperFunctions.isDarkMode(context)
                      ? TColors.darkBorder
                      : TColors.lightBorder),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    color: (THelperFunctions.isDarkMode(context)
                        ? TColors.textDarkTertiary
                        : TColors.textLightTertiary),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    currentSortLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: (THelperFunctions.isDarkMode(context)
                          ? TColors.textDarkTertiary
                          : TColors.textLightTertiary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
