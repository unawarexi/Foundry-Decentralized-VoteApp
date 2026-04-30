import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'atomic_widgets.dart';

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
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(StickyHeaderDelegate old) =>
      maxHeight != old.maxHeight ||
      minHeight != old.minHeight ||
      child != old.child;
}

class ForumStickyHeader extends StatelessWidget {
  final double scrollOffset;
  final Animation<double> headerFade;
  final Animation<Offset> headerSlide;
  final bool searchOpen;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final String filterCandidate;
  final VoidCallback onToggleSearch;
  final VoidCallback onShowFilter;
  final Function(String) onSearchChanged;
  final int tabIndex;
  final Function(int) onTabChanged;

  const ForumStickyHeader({
    super.key,
    required this.scrollOffset,
    required this.headerFade,
    required this.headerSlide,
    required this.searchOpen,
    required this.searchCtrl,
    required this.searchFocus,
    required this.filterCandidate,
    required this.onToggleSearch,
    required this.onShowFilter,
    required this.onSearchChanged,
    required this.tabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final collapsed = (scrollOffset / 60).clamp(0.0, 1.0);
    final isDark = THelperFunctions.isDarkMode(context);

    return FadeTransition(
      opacity: headerFade,
      child: SlideTransition(
        position: headerSlide,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: (isDark ? const Color(0xFF080F0B) : const Color(0xFFE8F0ED))
              .withOpacity(collapsed > 0.8 ? 1.0 : collapsed),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: searchOpen
                            ? SearchField(
                                key: const ValueKey('sf'),
                                ctrl: searchCtrl,
                                focus: searchFocus,
                                hint: 'Search questions, candidates…',
                                onChanged: onSearchChanged,
                              )
                            : Row(
                                key: const ValueKey('title'),
                                children: [
                                  Text(
                                    'Forum',
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSerif',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? TColors.white
                                          : TColors.black,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  AccentTag(label: 'PUBLIC Q&A'),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onToggleSearch,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: searchOpen
                              ? TColors.secondary.withOpacity(0.12)
                              : (isDark ? TColors.darkCard : TColors.lightCard),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: searchOpen
                                ? TColors.secondary.withOpacity(0.5)
                                : (isDark
                                      ? TColors.darkBorder
                                      : TColors.lightBorder),
                          ),
                        ),
                        child: AnimatedRotation(
                          turns: searchOpen ? 0.125 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            searchOpen ? Icons.close : Icons.search_rounded,
                            color: searchOpen
                                ? TColors.secondary
                                : (isDark
                                      ? TColors.textDarkTertiary
                                      : TColors.textLightTertiary),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onShowFilter,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: filterCandidate != 'All'
                              ? TColors.secondary.withOpacity(0.12)
                              : (isDark ? TColors.darkCard : TColors.lightCard),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: filterCandidate != 'All'
                                ? TColors.secondary.withOpacity(0.5)
                                : (isDark
                                      ? TColors.darkBorder
                                      : TColors.lightBorder),
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: filterCandidate != 'All'
                              ? TColors.secondary
                              : (isDark
                                    ? TColors.textDarkTertiary
                                    : TColors.textLightTertiary),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCategoryTabs(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    final tabs = ['Hot 🔥', 'New', 'Unanswered', 'Mine'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final on = tabIndex == i;
          return GestureDetector(
            onTap: () => onTabChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: on
                    ? TColors.primary.withOpacity(isDark ? 0.55 : 0.85)
                    : (isDark ? TColors.darkCard : TColors.lightCard),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: on
                      ? TColors.secondary.withOpacity(0.55)
                      : (isDark ? TColors.darkBorder : TColors.lightBorder),
                  width: on ? 1.2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tabs[i],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                      color: on
                          ? TColors.secondary
                          : (isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: on ? 18 : 0,
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
    );
  }
}
