import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

// Common Widgets
import 'widgets/home/painters.dart'; // GridPainter, HexRingPainter
import 'widgets/home/accent_tag.dart';

// Election Specific Widgets
import 'widgets/elections/elections_data.dart';
import 'widgets/elections/filter_chip_row.dart';
import 'widgets/elections/hero_card.dart';
import 'widgets/elections/election_list_card.dart';
import 'widgets/elections/sticky_header.dart';
import 'widgets/elections/sort_sheet.dart';

class ElectionsScreen extends StatefulWidget {
  const ElectionsScreen({super.key});

  @override
  State<ElectionsScreen> createState() => _ElectionsScreenState();
}

class _ElectionsScreenState extends State<ElectionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _countdownController;
  late AnimationController _filterController;
  late AnimationController _searchController;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  int _filterIndex = 0;
  bool _searchOpen = false;
  String _searchQuery = '';
  final _searchFocusNode = FocusNode();
  final _searchTextController = TextEditingController();

  Duration _featuredCountdown = const Duration(
    hours: 4,
    minutes: 22,
    seconds: 17,
  );

  late final ElectionsScreenAnimations _animations;

  static const List<String> _filterLabels = [
    'All',
    'Federal',
    'State',
    'Local Gov',
    'Campus',
    'Corporate',
  ];

  @override
  void initState() {
    super.initState();
    _buildControllers();

    _animations = ElectionsScreenAnimations(
      entranceController: _entranceController,
      shimmerController: _shimmerController,
      pulseController: _pulseController,
      searchController: _searchController,
    );

    _runEntrance();

    _scrollController.addListener(
      () => setState(() => _scrollOffset = _scrollController.offset),
    );

    _countdownController.addListener(() {
      if (_countdownController.value == 1.0) {
        setState(() {
          if (_featuredCountdown.inSeconds > 0) {
            _featuredCountdown -= const Duration(seconds: 1);
          }
        });
      }
    });
  }

  void _buildControllers() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _filterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _searchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  Future<void> _runEntrance() async {
    await Future.delayed(const Duration(milliseconds: 60));
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _shimmerController.forward();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _searchController.forward();
      Future.delayed(
        const Duration(milliseconds: 260),
        () => _searchFocusNode.requestFocus(),
      );
    } else {
      _searchController.reverse();
      _searchFocusNode.unfocus();
      _searchTextController.clear();
      setState(() => _searchQuery = '');
    }
  }

  List<ElectionData> get _filteredElections {
    final all = allElections;
    final label = _filterLabels[_filterIndex];
    var filtered = label == 'All'
        ? all
        : all.where((e) => e.level == label).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (e) =>
                e.title.toLowerCase().contains(q) ||
                e.region.toLowerCase().contains(q),
          )
          .toList();
    }
    return filtered;
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _countdownController.dispose();
    _filterController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: isDark
          ? TColors.darkBackground
          : TColors.lightBackground,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entranceController,
          _shimmerController,
          _pulseController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              // Layer 1: Gradient bg
              _buildBackground(isDark),

              // Layer 2: Grid texture
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: GridPainter(
                  color: TColors.secondary.withOpacity(isDark ? 0.04 : 0.08),
                ),
              ),

              // Layer 3: Corner hex decor
              Positioned(
                top: -60,
                left: -60,
                child: Opacity(
                  opacity: 0.055,
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: const HexRingPainter(),
                  ),
                ),
              ),

              // Layer 4: Shimmer sweep
              _buildShimmer(context),

              // Layer 5: Main content
              _buildBody(context, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    final parallax = (_scrollOffset * 0.0002).clamp(0.0, 0.15);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + parallax, -1),
          end: const Alignment(1, 1),
          colors: isDark
              ? const [
                  Color(0xFF080F0B),
                  TColors.darkBackground,
                  Color(0xFF0A0A14),
                ]
              : const [
                  Color(0xFFE8F0ED),
                  TColors.lightBackground,
                  Color(0xFFECECF4),
                ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return AnimatedBuilder(
      animation: _animations.shimmerPos,
      builder: (_, __) => Positioned.fill(
        child: IgnorePointer(
          child: Transform.translate(
            offset: Offset(
              MediaQuery.of(context).size.width *
                  (_animations.shimmerPos.value - 0.5) *
                  2,
              0,
            ),
            child: Container(
              width: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    TColors.secondary.withOpacity(0.05),
                    TColors.secondary.withOpacity(0.09),
                    TColors.secondary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    final live = _filteredElections
        .where((e) => e.status == ElectionStatus.live)
        .toList();
    final upcoming = _filteredElections
        .where((e) => e.status == ElectionStatus.upcoming)
        .toList();
    final closed = _filteredElections
        .where((e) => e.status == ElectionStatus.closed)
        .toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sticky header (search + title)
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeaderDelegate(
              minHeight: 60,
              maxHeight: 60,
              child: _buildStickyHeader(isDark),
            ),
          ),

          // ── Filter chips (horizontal scroll)
          SliverToBoxAdapter(
            child: FilterChipRow(
              filterLabels: _filterLabels,
              selectedIndex: _filterIndex,
              onChanged: (idx) {
                setState(() => _filterIndex = idx);
                _filterController.forward(from: 0);
              },
              filterFade: _animations.filterFade,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Featured hero card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HeroCard(
                heroFade: _animations.heroFade,
                heroSlide: _animations.heroSlide,
                pulseAnim: _animations.pulseAnim,
                countdown: _featuredCountdown,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── LIVE section
          if (live.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildGroupHeader(
                tag: 'LIVE NOW',
                tagColor: TColors.success,
                count: live.length,
                pulse: true,
                isDark: isDark,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: ElectionListCard(
                    data: live[i],
                    index: i,
                    listAnim: _animations.listFade,
                    slideAnim: _animations.listSlide,
                    pulseAnim: _animations.pulseAnim,
                  ),
                ),
                childCount: live.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],

          // ── UPCOMING section
          if (upcoming.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildGroupHeader(
                tag: 'UPCOMING',
                tagColor: TColors.secondary,
                count: upcoming.length,
                pulse: false,
                isDark: isDark,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: ElectionListCard(
                    data: upcoming[i],
                    index: i + live.length,
                    listAnim: _animations.listFade,
                    slideAnim: _animations.listSlide,
                    pulseAnim: _animations.pulseAnim,
                  ),
                ),
                childCount: upcoming.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],

          // ── CLOSED section
          if (closed.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildGroupHeader(
                tag: 'CLOSED',
                tagColor: isDark
                    ? TColors.textDarkTertiary
                    : TColors.textLightTertiary,
                count: closed.length,
                pulse: false,
                isDark: isDark,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: ElectionListCard(
                    data: closed[i],
                    index: i + live.length + upcoming.length,
                    listAnim: _animations.listFade,
                    slideAnim: _animations.listSlide,
                    pulseAnim: _animations.pulseAnim,
                  ),
                ),
                childCount: closed.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(bool isDark) {
    final collapsed = (_scrollOffset / 60).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: _animations.headerFade,
      child: SlideTransition(
        position: _animations.headerSlide,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: (isDark ? const Color(0xFF080F0B) : const Color(0xFFE8F0ED))
              .withOpacity(collapsed > 0.8 ? 1.0 : collapsed),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Title or search field
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _searchOpen
                      ? _buildSearchField(isDark)
                      : Row(
                          key: const ValueKey('title'),
                          children: [
                            Flexible(
                              child: Text(
                                'Elections',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSerif',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? TColors.white : TColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(child: AccentTag(label: 'GLOBAL')),
                          ],
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Search toggle
              GestureDetector(
                onTap: _toggleSearch,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _searchOpen
                        ? TColors.secondary.withOpacity(0.12)
                        : (isDark ? TColors.darkCard : TColors.lightCard),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _searchOpen
                          ? TColors.secondary.withOpacity(0.5)
                          : (isDark ? TColors.darkBorder : TColors.lightBorder),
                    ),
                  ),
                  child: AnimatedRotation(
                    turns: _searchOpen ? 0.125 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      _searchOpen ? Icons.close : Icons.search_rounded,
                      color: _searchOpen
                          ? TColors.secondary
                          : (isDark
                                ? TColors.textDarkSecondary
                                : TColors.textLightSecondary),
                      size: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Filter / sort icon
              GestureDetector(
                onTap: () => _showSortSheet(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? TColors.darkCard : TColors.lightCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? TColors.darkBorder : TColors.lightBorder,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: isDark
                        ? TColors.textDarkSecondary
                        : TColors.textLightSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return FadeTransition(
      key: const ValueKey('search'),
      opacity: _animations.searchExpandAnim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? TColors.darkCard : TColors.lightCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TColors.secondary.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: TColors.secondary.withOpacity(0.06),
              blurRadius: 10,
            ),
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
                controller: _searchTextController,
                focusNode: _searchFocusNode,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: isDark
                      ? TColors.textDarkPrimary
                      : TColors.textLightPrimary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search elections, regions…',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: isDark
                        ? TColors.textDarkTertiary
                        : TColors.textLightTertiary,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader({
    required String tag,
    required Color tagColor,
    required int count,
    required bool pulse,
    required bool isDark,
  }) {
    return FadeTransition(
      opacity: _animations.listFade,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Row(
          children: [
            if (pulse)
              AnimatedBuilder(
                animation: _animations.pulseAnim,
                builder: (_, __) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tagColor.withOpacity(
                      0.6 + 0.4 * _animations.pulseAnim.value,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tagColor.withOpacity(
                          0.4 * _animations.pulseAnim.value,
                        ),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            Text(
              tag,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: tagColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: tagColor.withOpacity(0.3)),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: tagColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'See all →',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: TColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SortSheet(),
    );
  }
}
