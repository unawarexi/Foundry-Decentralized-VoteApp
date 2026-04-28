import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// import 'package:your_app/core/theme/colors.dart';
// import 'package:your_app/core/animations/entrance_animation.dart';  // splash_screen.dart
// import 'package:your_app/core/animations/shimmer_sweep.dart';        // splash_screen.dart
// import 'package:your_app/core/widgets/accent_tag.dart';              // onboarding_screen.dart
// import 'package:your_app/core/painters/grid_painter.dart';           // splash_screen.dart
// import 'package:your_app/core/painters/mini_logo_painter.dart';      // auth_screens.dart
// import 'package:your_app/core/painters/hex_ring_painter.dart';       // auth_screens.dart

/// VoteSecure — Elections Screen (Tab 2)
///
/// Layout:
///   SliverAppBar (sticky search + filter bar)
///   → Filter chip row (All · Federal · State · Local · Campus)
///   → Featured election hero card (full-width, countdown)
///   → Vertical list of election cards grouped by status
///     (LIVE · UPCOMING · CLOSED)
///
/// Animation strategy (all reuse controllers from previous screens):
///   _entranceController  → staggered Interval fades (same as home_screen.dart)
///   _shimmerController   → one-shot gold sweep (same as splash_screen.dart)
///   _pulseController     → repeating live dots (same as home_screen.dart)
///   _countdownController → ticker that rebuilds countdown every second
///   _filterController    → AnimatedContainer slide for filter selection
///   _heroController      → hero card parallax on scroll
class ElectionsScreen extends StatefulWidget {
  const ElectionsScreen({super.key});

  @override
  State<ElectionsScreen> createState() => _ElectionsScreenState();
}

class _ElectionsScreenState extends State<ElectionsScreen>
    with TickerProviderStateMixin {
  // ── Entrance (same as home_screen.dart) ──────────────────────
  late AnimationController _entranceController;

  // ── One-shot shimmer (same as splash_screen.dart) ─────────────
  late AnimationController _shimmerController;

  // ── Live badge pulse (same as home_screen.dart) ───────────────
  late AnimationController _pulseController;

  // ── Countdown ticker — rebuilds every second ──────────────────
  // ANIMATION_TYPE: Periodic AnimationController (duration: 1 second, repeat)
  // drives a ValueNotifier<Duration> for the featured election countdown.
  // Text flips using AnimatedSwitcher with a vertical slide (like a flip clock)
  late AnimationController _countdownController;

  // ── Filter chip slide indicator ───────────────────────────────
  // ANIMATION_TYPE: AnimatedContainer width + position shift
  // same technique as step indicator bars in signup_screen.dart
  late AnimationController _filterController;

  // ── Search bar expand ─────────────────────────────────────────
  // ANIMATION_TYPE: AnimatedContainer width 0 → full, FadeTransition
  // triggered on search icon tap
  late AnimationController _searchController;

  // ── Scroll ────────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  // ── State ─────────────────────────────────────────────────────
  int _filterIndex = 0; // selected filter chip
  bool _searchOpen = false;
  String _searchQuery = '';
  final _searchFocusNode = FocusNode();
  final _searchTextController = TextEditingController();

  // ── Countdown state ───────────────────────────────────────────
  Duration _featuredCountdown = const Duration(
    hours: 4,
    minutes: 22,
    seconds: 17,
  );

  // ── Staggered entrance animations (same Interval system) ──────
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _filterFade;
  late Animation<double> _listFade;
  late Animation<Offset> _listSlide;
  late Animation<double> _shimmerPos;
  late Animation<double> _pulseAnim;
  late Animation<double> _searchExpandAnim;

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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _buildControllers();
    _buildAnimations();
    _runEntrance();

    _scrollController.addListener(
      () => setState(() => _scrollOffset = _scrollController.offset),
    );

    // Countdown tick — rebuilds state every second
    // ANIMATION_TYPE: Periodic ticker using AnimationController.repeat()
    // Each tick decrements _featuredCountdown by 1 second
    // Digits animate via AnimatedSwitcher + _CountdownDigit widget (flip)
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
    // ANIMATION_SLOT_1: Main entrance — 1100ms, matching home_screen.dart
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // ANIMATION_SLOT_2: Gold shimmer sweep (one-shot, splash_screen.dart)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // ANIMATION_SLOT_3: Live pulse (repeating, home_screen.dart)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // ANIMATION_SLOT_4: Countdown — 1 second period, repeat forever
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // ANIMATION_SLOT_5: Filter selection — 300ms ease
    _filterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // ANIMATION_SLOT_6: Search bar expand — 250ms ease
    _searchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _buildAnimations() {
    // Header (search bar row)
    // ANIMATION_TYPE: FadeTransition + SlideTransition from top
    // Interval(0.0, 0.35) — same as home_screen.dart topbar
    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _headerSlide = Tween(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
          ),
        );

    // Filter chips
    // ANIMATION_TYPE: FadeTransition, Interval(0.1, 0.45)
    // each chip gets per-index delay: i * 0.04 added to Interval start
    _filterFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.45, curve: Curves.easeOut),
    );

    // Hero featured card
    // ANIMATION_TYPE: FadeTransition + SlideTransition from below
    // ScaleTransition 0.94→1.0 for "surface rising" feel
    // Interval(0.2, 0.6)
    _heroFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _heroSlide = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    // Election list cards
    // ANIMATION_TYPE: FadeTransition + SlideTransition, Interval(0.45, 0.85)
    // Per-card stagger: index * 0.06 offset within list
    _listFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );
    _listSlide = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
      ),
    );

    // Shimmer (same as splash_screen.dart)
    _shimmerPos = Tween(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Pulse
    _pulseAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Search expand
    // ANIMATION_TYPE: CurvedAnimation drives AnimatedContainer width
    // Curves.easeOut — same feel as field focus in auth_screens.dart
    _searchExpandAnim = CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeOut,
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

  List<_ElectionData> get _filteredElections {
    final all = _allElections;
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
    return Scaffold(
      backgroundColor: TColors.darkBackground,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entranceController,
          _shimmerController,
          _pulseController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              // Layer 1: Gradient bg (home_screen.dart pattern)
              _buildBackground(),

              // Layer 2: Grid texture (splash_screen.dart _GridPainter)
              Opacity(
                opacity: 0.04,
                child: CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _GridPainter(color: TColors.secondary),
                ),
              ),

              // Layer 3: Corner hex decor (auth_screens.dart _HexRingPainter)
              Positioned(
                top: -60,
                left: -60,
                child: Opacity(
                  opacity: 0.055,
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: _HexRingPainter(),
                  ),
                ),
              ),

              // Layer 4: Shimmer sweep (splash_screen.dart one-shot)
              _buildShimmer(context),

              // Layer 5: Main content
              _buildBody(context),
            ],
          );
        },
      ),
    );
  }

  // ── Background ─────────────────────────────────────────────

  Widget _buildBackground() {
    final parallax = (_scrollOffset * 0.0002).clamp(0.0, 0.15);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + parallax, -1),
          end: const Alignment(1, 1),
          colors: const [
            Color(0xFF080F0B),
            TColors.darkBackground,
            Color(0xFF0A0A14),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }

  // ANIMATION_TYPE: AnimatedBuilder(_shimmerPos) + Transform.translate
  // Identical to splash_screen.dart shimmer layer
  Widget _buildShimmer(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerPos,
      builder: (_, __) => Positioned.fill(
        child: IgnorePointer(
          child: Transform.translate(
            offset: Offset(
              MediaQuery.of(context).size.width * (_shimmerPos.value - 0.5) * 2,
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

  // ── Body ───────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    final live = _filteredElections
        .where((e) => e.status == _ElectionStatus.live)
        .toList();
    final upcoming = _filteredElections
        .where((e) => e.status == _ElectionStatus.upcoming)
        .toList();
    final closed = _filteredElections
        .where((e) => e.status == _ElectionStatus.closed)
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
            delegate: _StickyHeaderDelegate(
              minHeight: 60,
              maxHeight: 60,
              child: _buildStickyHeader(),
            ),
          ),

          // ── Filter chips (horizontal scroll)
          SliverToBoxAdapter(child: _buildFilterRow()),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Featured hero card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHeroCard(),
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
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _ElectionListCard(
                    data: live[i],
                    index: i,
                    listAnim: _listFade,
                    slideAnim: _listSlide,
                    pulseAnim: _pulseAnim,
                    // ANIMATION_TYPE: Per-card staggered FadeTransition
                    // delay = index * 0.06 within listAnim Interval
                    // Same pattern as upcoming tiles in home_screen.dart
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
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _ElectionListCard(
                    data: upcoming[i],
                    index: i + live.length,
                    listAnim: _listFade,
                    slideAnim: _listSlide,
                    pulseAnim: _pulseAnim,
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
                tagColor: TColors.textDarkTertiary,
                count: closed.length,
                pulse: false,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _ElectionListCard(
                    data: closed[i],
                    index: i + live.length + upcoming.length,
                    listAnim: _listFade,
                    slideAnim: _listSlide,
                    pulseAnim: _pulseAnim,
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

  // ── Sticky header ──────────────────────────────────────────

  Widget _buildStickyHeader() {
    final collapsed = (_scrollOffset / 60).clamp(0.0, 1.0);

    // ANIMATION_TYPE: FadeTransition(_headerFade) + SlideTransition(_headerSlide)
    // On scroll: AnimatedContainer color opacity 0→0.95 (same as home_screen.dart topbar)
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: TColors.darkBackground.withOpacity(0.7 + 0.25 * collapsed),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Title or search field
              Expanded(
                child: AnimatedSwitcher(
                  // ANIMATION_TYPE: AnimatedSwitcher with FadeTransition
                  // switches between title text and TextField
                  // same Curves.easeOut timing as auth field focus
                  duration: const Duration(milliseconds: 220),
                  child: _searchOpen
                      ? _buildSearchField()
                      : Row(
                          key: const ValueKey('title'),
                          children: [
                            Text(
                              'Elections',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSerif',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: TColors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _AccentTag(label: 'GLOBAL'),
                          ],
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Search toggle
              // ANIMATION_TYPE: AnimatedRotation 0→π/4 (icon morphs search→close)
              // 200ms Curves.easeOut
              GestureDetector(
                onTap: _toggleSearch,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _searchOpen
                        ? TColors.secondary.withOpacity(0.12)
                        : TColors.darkCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _searchOpen
                          ? TColors.secondary.withOpacity(0.5)
                          : TColors.darkBorder,
                    ),
                  ),
                  child: AnimatedRotation(
                    // ANIMATION_TYPE: AnimatedRotation 0→0.125 turns (= π/4 radians)
                    // morphs search icon orientation on open
                    turns: _searchOpen ? 0.125 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      _searchOpen ? Icons.close : Icons.search_rounded,
                      color: _searchOpen
                          ? TColors.secondary
                          : TColors.textDarkSecondary,
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
                    color: TColors.darkCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: TColors.darkBorder),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: TColors.textDarkSecondary,
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

  Widget _buildSearchField() {
    // ANIMATION_TYPE: FadeTransition driven by _searchExpandAnim
    // TextField slides in from right — same as field entrance in auth_screens.dart
    return FadeTransition(
      key: const ValueKey('search'),
      opacity: _searchExpandAnim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 38,
        decoration: BoxDecoration(
          color: TColors.darkCard,
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
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: TColors.textDarkPrimary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search elections, regions…',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: TColors.textDarkTertiary,
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

  // ── Filter chips ───────────────────────────────────────────

  Widget _buildFilterRow() {
    // ANIMATION_TYPE: FadeTransition(_filterFade)
    // Each chip: AnimatedContainer color/border (same as nav item in home_screen.dart)
    // Selected chip underline: AnimatedContainer width 0→full (signup step bars)
    return FadeTransition(
      opacity: _filterFade,
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filterLabels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final selected = _filterIndex == i;
            return GestureDetector(
              onTap: () {
                setState(() => _filterIndex = i);
                // ANIMATION_TYPE: _filterController.forward(from: 0)
                // triggers AnimatedContainer indicator slide
              },
              child: AnimatedContainer(
                // ANIMATION_TYPE: AnimatedContainer 250ms Curves.easeOut
                // background, border, padding shift on selection
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? TColors.primary.withOpacity(0.55)
                      : TColors.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? TColors.secondary.withOpacity(0.55)
                        : TColors.darkBorder,
                    width: selected ? 1.2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _filterLabels[i],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? TColors.secondary
                            : TColors.textDarkTertiary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ANIMATION_TYPE: AnimatedContainer width 0→18px
                    // same as step bars in signup_screen.dart
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

  // ── Hero featured card ─────────────────────────────────────

  Widget _buildHeroCard() {
    // ANIMATION_TYPE: FadeTransition(_heroFade) + SlideTransition(_heroSlide)
    // + ScaleTransition from 0.94→1.0 — "surface rising" on entrance
    // Inner countdown: AnimatedSwitcher per digit (flip clock vertical slide)
    // Participation bar: AnimatedContainer width 0→72% driven by _heroFade
    // Border pulse: AnimatedBuilder(_pulseAnim) opacity flicker on gold border
    final h = _featuredCountdown.inHours;
    final m = _featuredCountdown.inMinutes.remainder(60);
    final s = _featuredCountdown.inSeconds.remainder(60);

    return FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2B1E), Color(0xFF111128)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: TColors.secondary.withOpacity(
                  0.3 + 0.15 * _pulseAnim.value,
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(
                    0.3 + 0.1 * _pulseAnim.value,
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Watermark hex (top-right)
                Positioned(
                  top: -30,
                  right: -30,
                  child: Opacity(
                    opacity: 0.07,
                    child: CustomPaint(
                      size: const Size(160, 160),
                      painter: _HexRingPainter(),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: tag + FEATURED badge
                      Row(
                        children: [
                          _AccentTag(label: 'STATE · FEATURED'),
                          const Spacer(),
                          _LiveBadge(pulse: _pulseAnim.value, label: 'LIVE'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Election title
                      Text(
                        'Edo State Gubernatorial\nElection 2024',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSerif',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: TColors.white,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: TColors.textDarkTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Benin City · Edo State · Nigeria',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: TColors.textDarkTertiary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Gold rule
                      Container(
                        width: 36,
                        height: 1.5,
                        color: TColors.secondary,
                      ),

                      const SizedBox(height: 20),

                      // Countdown row
                      // ANIMATION_TYPE: AnimatedSwitcher per segment
                      // Each digit (h/m/s) wraps in AnimatedSwitcher with
                      // SlideTransition(begin: Offset(0, -0.5)) — flip clock effect
                      Row(
                        children: [
                          _CountdownBlock(
                            value: h.toString().padLeft(2, '0'),
                            label: 'HRS',
                          ),
                          _CountdownSeparator(),
                          _CountdownBlock(
                            value: m.toString().padLeft(2, '0'),
                            label: 'MIN',
                          ),
                          _CountdownSeparator(),
                          _CountdownBlock(
                            value: s.toString().padLeft(2, '0'),
                            label: 'SEC',
                          ),
                          const Spacer(),
                          // Cast vote CTA
                          _HeroCTAButton(pulse: _pulseAnim.value),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Participation bar
                      _ParticipationBar(
                        percent: 68,
                        entranceAnim: _heroFade,
                        // ANIMATION_TYPE: AnimatedContainer width from 0→68%
                        // driven by _heroFade value (0.0→1.0)
                        // same technique as election card progress in home_screen.dart
                      ),

                      const SizedBox(height: 16),

                      // Stat row: candidates · registered voters · fee
                      Row(
                        children: const [
                          _HeroStat(value: '7', label: 'Candidates'),
                          _HeroStatDivider(),
                          _HeroStat(value: '2.4M', label: 'Registered'),
                          _HeroStatDivider(),
                          _HeroStat(value: '\$1 USDT', label: 'Vote Fee'),
                          _HeroStatDivider(),
                          _HeroStat(value: 'ZK', label: 'Privacy'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Group header ───────────────────────────────────────────

  Widget _buildGroupHeader({
    required String tag,
    required Color tagColor,
    required int count,
    required bool pulse,
  }) {
    // ANIMATION_TYPE: FadeTransition(_listFade) with Interval stagger
    return FadeTransition(
      opacity: _listFade,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Row(
          children: [
            if (pulse)
              AnimatedBuilder(
                // ANIMATION_TYPE: AnimatedBuilder(_pulseAnim)
                // same _LiveDot mechanic from home_screen.dart
                animation: _pulseAnim,
                builder: (_, __) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tagColor.withOpacity(0.6 + 0.4 * _pulseAnim.value),
                    boxShadow: [
                      BoxShadow(
                        color: tagColor.withOpacity(0.4 * _pulseAnim.value),
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

  // ── Sort bottom sheet ──────────────────────────────────────

  void _showSortSheet(BuildContext context) {
    // ANIMATION_TYPE: showModalBottomSheet with custom slide-up transition
    // same as the exit transition mechanic in splash_screen.dart
    // DraggableScrollableSheet with snap points
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SortSheet(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ELECTION LIST CARD
// ══════════════════════════════════════════════════════════════

class _ElectionListCard extends StatefulWidget {
  final _ElectionData data;
  final int index;
  final Animation<double> listAnim;
  final Animation<Offset> slideAnim;
  final Animation<double> pulseAnim;

  const _ElectionListCard({
    required this.data,
    required this.index,
    required this.listAnim,
    required this.slideAnim,
    required this.pulseAnim,
  });

  @override
  State<_ElectionListCard> createState() => _ElectionListCardState();
}

class _ElectionListCardState extends State<_ElectionListCard>
    with SingleTickerProviderStateMixin {
  // ANIMATION_TYPE: ScaleTransition 1.0→0.97 on tap
  // same press mechanic as _ElectionCard in home_screen.dart
  late AnimationController _pressCtrl;

  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    // Per-card stagger: delay based on index
    // ANIMATION_TYPE: CurvedAnimation with Interval(index*0.06, 1.0)
    // applied to widget.listAnim — same technique as onboarding slide triggers
    final staggeredFade = CurvedAnimation(
      parent: widget.listAnim,
      curve: Interval(
        (widget.index * 0.06).clamp(0.0, 0.6),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: staggeredFade,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.reverse(),
        onTapUp: (_) {
          _pressCtrl.forward();
          setState(() => _expanded = !_expanded);
        },
        onTapCancel: () => _pressCtrl.forward(),
        child: AnimatedBuilder(
          // ANIMATION_TYPE: AnimatedBuilder on _pressCtrl for scale
          animation: _pressCtrl,
          builder: (_, child) =>
              Transform.scale(scale: _pressCtrl.value, child: child),
          child: AnimatedContainer(
            // ANIMATION_TYPE: AnimatedContainer height expands when _expanded
            // reveals candidate preview list below the main card info
            // Curves.easeOut 300ms — deliberate, not bouncy
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: TColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _statusBorderColor(d.status, widget.pulseAnim.value),
                width: d.status == _ElectionStatus.live ? 1.2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _statusGlowColor(d.status).withOpacity(0.1),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top row: level tag + status badge + chevron
                      Row(
                        children: [
                          _AccentTag(label: d.level),
                          const SizedBox(width: 8),
                          if (d.status == _ElectionStatus.live)
                            _LiveBadge(
                              pulse: widget.pulseAnim.value,
                              label: 'LIVE',
                            ),
                          if (d.status == _ElectionStatus.upcoming)
                            _StatusChip(
                              label: 'UPCOMING',
                              color: TColors.secondary,
                            ),
                          if (d.status == _ElectionStatus.closed)
                            _StatusChip(
                              label: 'CLOSED',
                              color: TColors.textDarkTertiary,
                            ),
                          const Spacer(),
                          // ANIMATION_TYPE: AnimatedRotation 0→0.5 turns
                          // chevron spins 180° when card expands
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: TColors.textDarkTertiary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Election title
                      Text(
                        d.title,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSerif',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TColors.white,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ── Region + date row
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: TColors.textDarkTertiary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            d.region,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: TColors.textDarkTertiary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: d.status == _ElectionStatus.live
                                ? TColors.accent
                                : TColors.textDarkTertiary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            d.timeDisplay,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: d.status == _ElectionStatus.live
                                  ? TColors.accent
                                  : TColors.textDarkTertiary,
                              fontWeight: d.status == _ElectionStatus.live
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── Participation bar
                      if (d.participation > 0) ...[
                        _ParticipationBar(
                          percent: d.participation,
                          entranceAnim: widget.listAnim,
                          // ANIMATION_TYPE: AnimatedContainer width 0→percent%
                          // same as hero card participation bar
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ── Bottom: candidates + fee + bookmark
                      Row(
                        children: [
                          // Candidates count
                          _MiniStat(
                            icon: Icons.person_outline_rounded,
                            value: '${d.candidates}',
                            label: 'candidates',
                          ),
                          const SizedBox(width: 14),
                          // Vote fee
                          _MiniStat(
                            icon: Icons.toll_outlined,
                            value: '\$1',
                            label: 'USDT fee',
                          ),
                          const Spacer(),
                          // Bookmark button
                          // ANIMATION_TYPE: ScaleTransition 1.0→1.25→1.0 on tap
                          // "heart tap" spring — TweenSequence same as badge pulse
                          _BookmarkButton(isBookmarked: d.isBookmarked),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Expanded: candidate preview list
                // ANIMATION_TYPE: ClipRect + SizeTransition height 0→auto
                // Curves.easeOut 300ms — same timing as AnimatedContainer above
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: _expanded
                      ? _CandidatePreviewList(candidates: d.candidates)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusBorderColor(_ElectionStatus s, double pulse) {
    switch (s) {
      case _ElectionStatus.live:
        return TColors.accent.withOpacity(0.3 + 0.2 * pulse);
      case _ElectionStatus.upcoming:
        return TColors.darkBorder;
      case _ElectionStatus.closed:
        return TColors.darkBorder.withOpacity(0.5);
    }
  }

  Color _statusGlowColor(_ElectionStatus s) {
    switch (s) {
      case _ElectionStatus.live:
        return TColors.accent;
      case _ElectionStatus.upcoming:
        return TColors.secondary;
      case _ElectionStatus.closed:
        return Colors.transparent;
    }
  }
}

// ══════════════════════════════════════════════════════════════
// CANDIDATE PREVIEW LIST (expanded section)
// ══════════════════════════════════════════════════════════════

class _CandidatePreviewList extends StatelessWidget {
  final int candidates;
  const _CandidatePreviewList({required this.candidates});

  @override
  Widget build(BuildContext context) {
    final items = _mockCandidates.take(candidates.clamp(0, 4)).toList();
    return Column(
      children: [
        Divider(height: 1, color: TColors.darkBorder),
        // ANIMATION_TYPE: ListView items use per-index FadeTransition
        // staggered with Interval(i*0.1, 1.0) on parent AnimatedSize completion
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return _CandidateRow(candidate: c, index: i);
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View all candidates →',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: TColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final _CandidateData candidate;
  final int index;
  const _CandidateRow({required this.candidate, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Avatar initials
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  TColors.primary.withOpacity(0.8),
                  TColors.secondaryAlt.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: TColors.secondary.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                candidate.initials,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSerif',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: TColors.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + party
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: TColors.textDarkPrimary,
                  ),
                ),
                Text(
                  candidate.party,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: TColors.textDarkTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Poll percentage bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${candidate.pollPct}%',
                style: const TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TColors.secondary,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  // ANIMATION_TYPE: LinearProgressIndicator value animates
                  // from 0 to candidate.pollPct/100 using TweenAnimationBuilder
                  // duration 600ms Curves.easeOut on expand
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: candidate.pollPct / 100),
                    duration: Duration(milliseconds: 500 + index * 100),
                    curve: Curves.easeOut,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      backgroundColor: TColors.darkBorder,
                      valueColor: AlwaysStoppedAnimation(
                        index == 0
                            ? TColors.secondary
                            : TColors.textDarkTertiary.withOpacity(0.5),
                      ),
                      minHeight: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SORT BOTTOM SHEET
// ══════════════════════════════════════════════════════════════

class _SortSheet extends StatelessWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context) {
    // ANIMATION_TYPE: BottomSheet uses default slide-up
    // Internal items: per-row FadeTransition stagger (same list pattern)
    return Container(
      decoration: const BoxDecoration(
        color: TColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: TColors.darkBorder),
          left: BorderSide(color: TColors.darkBorder),
          right: BorderSide(color: TColors.darkBorder),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: TColors.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sort & Filter',
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: TColors.white,
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
                      color: TColors.darkBorder.withOpacity(i < 4 ? 1 : 0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(item.$2, color: TColors.textDarkTertiary, size: 18),
                    const SizedBox(width: 14),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: TColors.textDarkSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: TColors.darkBorder,
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

// ══════════════════════════════════════════════════════════════
// ATOMIC SUBWIDGETS
// ══════════════════════════════════════════════════════════════

// ── Countdown block ────────────────────────────────────────────
class _CountdownBlock extends StatelessWidget {
  final String value;
  final String label;
  const _CountdownBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 52,
          decoration: BoxDecoration(
            color: TColors.darkElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TColors.darkBorder),
          ),
          child: Center(
            child: AnimatedSwitcher(
              // ANIMATION_TYPE: AnimatedSwitcher with vertical SlideTransition
              // begin: Offset(0, -0.4) → Offset.zero (flip clock downward)
              // duration: 300ms Curves.easeOut
              // triggers every second when _featuredCountdown changes
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
                style: const TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: TColors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 8.5,
            color: TColors.textDarkTertiary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _CountdownSeparator extends StatelessWidget {
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

// ── Hero CTA ───────────────────────────────────────────────────
class _HeroCTAButton extends StatelessWidget {
  final double pulse;
  const _HeroCTAButton({required this.pulse});

  @override
  Widget build(BuildContext context) {
    // ANIMATION_TYPE: box-shadow oscillates via _pulseAnim
    // same as Cast Vote button in home_screen.dart identity card
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.accent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: TColors.accent.withOpacity(0.3 + 0.2 * pulse),
              blurRadius: 16 + 6 * pulse,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: const [
            Icon(Icons.how_to_vote_outlined, color: TColors.white, size: 20),
            SizedBox(height: 4),
            Text(
              'Vote',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: TColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Participation bar ──────────────────────────────────────────
class _ParticipationBar extends StatelessWidget {
  final int percent;
  final Animation<double> entranceAnim;
  const _ParticipationBar({required this.percent, required this.entranceAnim});

  @override
  Widget build(BuildContext context) {
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
                color: TColors.textDarkTertiary,
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
            // ANIMATION_TYPE: AnimatedBuilder on entranceAnim
            // bar width grows from 0 → percent% as entrance completes
            animation: entranceAnim,
            builder: (_, __) => LinearProgressIndicator(
              value: (percent / 100) * entranceAnim.value,
              backgroundColor: TColors.darkBorder,
              valueColor: AlwaysStoppedAnimation(TColors.secondary),
              minHeight: 5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero stat ──────────────────────────────────────────────────
class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: TColors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            color: TColors.textDarkTertiary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _HeroStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: TColors.darkBorder,
    );
  }
}

// ── Mini stat ──────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: TColors.textDarkTertiary),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: TColors.textDarkTertiary,
          ),
        ),
      ],
    );
  }
}

// ── Live badge ─────────────────────────────────────────────────
class _LiveBadge extends StatelessWidget {
  final double pulse;
  final String label;
  const _LiveBadge({required this.pulse, required this.label});

  @override
  Widget build(BuildContext context) {
    // ANIMATION_TYPE: background opacity oscillates via pulseAnim
    // same as _GlobalFeedTile live badge in home_screen.dart
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: TColors.success.withOpacity(0.08 + 0.05 * pulse),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: TColors.success.withOpacity(0.3 + 0.2 * pulse),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.success.withOpacity(0.7 + 0.3 * pulse),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: TColors.success,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status chip ────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Bookmark button ────────────────────────────────────────────
class _BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  const _BookmarkButton({required this.isBookmarked});

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late bool _saved;
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _saved = widget.isBookmarked;
    // ANIMATION_TYPE: TweenSequence 1.0→1.3→1.0 on tap
    // "bookmark spring" — same concept as badge pulse but triggered once
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _bounceAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _saved = !_saved);
        _bounceCtrl.forward(from: 0);
      },
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (_, __) => Transform.scale(
          scale: _bounceAnim.value,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _saved
                  ? TColors.secondary.withOpacity(0.12)
                  : TColors.darkElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _saved
                    ? TColors.secondary.withOpacity(0.45)
                    : TColors.darkBorder,
              ),
            ),
            child: Icon(
              _saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _saved ? TColors.secondary : TColors.textDarkTertiary,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Accent tag ─────────────────────────────────────────────────
// Identical to all previous screens — refactored from onboarding_screen.dart
class _AccentTag extends StatelessWidget {
  final String label;
  const _AccentTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.secondary.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: TColors.secondary.withOpacity(0.08),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: TColors.secondary,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SLIVER PERSISTENT HEADER DELEGATE
// ══════════════════════════════════════════════════════════════

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  const _StickyHeaderDelegate({
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
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate old) =>
      maxHeight != old.maxHeight ||
      minHeight != old.minHeight ||
      child != old.child;
}

// ══════════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════════

enum _ElectionStatus { live, upcoming, closed }

class _ElectionData {
  final String title;
  final String region;
  final String level;
  final _ElectionStatus status;
  final int participation;
  final String timeDisplay;
  final int candidates;
  final bool isBookmarked;

  const _ElectionData({
    required this.title,
    required this.region,
    required this.level,
    required this.status,
    required this.participation,
    required this.timeDisplay,
    required this.candidates,
    this.isBookmarked = false,
  });
}

class _CandidateData {
  final String name;
  final String initials;
  final String party;
  final int pollPct;

  const _CandidateData({
    required this.name,
    required this.initials,
    required this.party,
    required this.pollPct,
  });
}

// ══════════════════════════════════════════════════════════════
// MOCK DATA
// ══════════════════════════════════════════════════════════════

const List<_ElectionData> _allElections = [
  // ── LIVE
  _ElectionData(
    title: 'Edo State Gubernatorial Election 2024',
    region: 'Benin City · Edo State',
    level: 'State',
    status: _ElectionStatus.live,
    participation: 68,
    timeDisplay: '4h 22m left',
    candidates: 7,
    isBookmarked: true,
  ),
  _ElectionData(
    title: 'Lagos Local Government Area Chairman',
    region: 'Ikeja · Lagos State',
    level: 'Local Gov',
    status: _ElectionStatus.live,
    participation: 55,
    timeDisplay: '11h 08m left',
    candidates: 5,
  ),
  _ElectionData(
    title: 'University of Benin Student Union President',
    region: 'Ugbowo Campus · NG',
    level: 'Campus',
    status: _ElectionStatus.live,
    participation: 42,
    timeDisplay: '2d 4h left',
    candidates: 4,
  ),
  // ── UPCOMING
  _ElectionData(
    title: 'Federal House of Representatives — Edo North',
    region: 'Etsako West · Edo State',
    level: 'Federal',
    status: _ElectionStatus.upcoming,
    participation: 0,
    timeDisplay: 'Jun 3, 2024',
    candidates: 6,
  ),
  _ElectionData(
    title: 'Abuja FCT Senatorial District Poll',
    region: 'Federal Capital Territory',
    level: 'Federal',
    status: _ElectionStatus.upcoming,
    participation: 0,
    timeDisplay: 'May 12, 2024',
    candidates: 4,
    isBookmarked: true,
  ),
  _ElectionData(
    title: 'Rivers State Local Council Elections',
    region: 'Port Harcourt · Rivers State',
    level: 'Local Gov',
    status: _ElectionStatus.upcoming,
    participation: 0,
    timeDisplay: 'May 19, 2024',
    candidates: 8,
  ),
  _ElectionData(
    title: 'Zenith Bank Board of Directors Election',
    region: 'Lagos · Corporate',
    level: 'Corporate',
    status: _ElectionStatus.upcoming,
    participation: 0,
    timeDisplay: 'May 30, 2024',
    candidates: 3,
  ),
  // ── CLOSED
  _ElectionData(
    title: 'Kano State Gubernatorial Election 2023',
    region: 'Kano · Kano State',
    level: 'State',
    status: _ElectionStatus.closed,
    participation: 81,
    timeDisplay: 'Closed Mar 18',
    candidates: 5,
  ),
  _ElectionData(
    title: 'Covenant University SUG Elections',
    region: 'Ota · Ogun State',
    level: 'Campus',
    status: _ElectionStatus.closed,
    participation: 77,
    timeDisplay: 'Closed Apr 2',
    candidates: 3,
  ),
];

const List<_CandidateData> _mockCandidates = [
  _CandidateData(
    name: 'Monday Okpebholo',
    initials: 'MO',
    party: 'APC · All Progressives Congress',
    pollPct: 38,
  ),
  _CandidateData(
    name: 'Asue Ighodalo',
    initials: 'AI',
    party: 'PDP · Peoples Democratic Party',
    pollPct: 34,
  ),
  _CandidateData(
    name: 'Olumide Akpata',
    initials: 'OA',
    party: 'LP · Labour Party',
    pollPct: 18,
  ),
  _CandidateData(
    name: 'Kenneth Imasuangbon',
    initials: 'KI',
    party: 'IND · Independent',
    pollPct: 10,
  ),
];

// ══════════════════════════════════════════════════════════════
// PAINTERS (same as all previous screens — refactored imports)
// ══════════════════════════════════════════════════════════════

class _HexRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (int ring = 1; ring <= 3; ring++) {
      final r = size.width * 0.15 * ring;
      final hexPath = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (math.pi / 3) * i - math.pi / 6;
        final x = c.dx + r * math.cos(angle);
        final y = c.dy + r * math.sin(angle);
        if (i == 0)
          hexPath.moveTo(x, y);
        else
          hexPath.lineTo(x, y);
      }
      hexPath.close();
      canvas.drawPath(
        hexPath,
        Paint()
          ..color = TColors.secondary.withOpacity(0.5 / ring)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const spacing = 36.0;
    for (double x = 0; x <= size.width; x += spacing)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y <= size.height; y += spacing)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Color shim — remove when importing colors.dart ────────────
class TColors {
  static const primary = Color(0xFF0B3D2E);
  static const primaryDark = Color(0xFF0F5132);
  static const secondary = Color(0xFFC6A75E);
  static const secondaryAlt = Color(0xFF1A1A40);
  static const accent = Color(0xFFD96C2D);
  static const darkBackground = Color(0xFF0A0A0A);
  static const darkSurface = Color(0xFF121212);
  static const darkCard = Color(0xFF18181B);
  static const darkElevated = Color(0xFF1E1E24);
  static const darkBorder = Color(0xFF2A2A2A);
  static const textDarkPrimary = Color(0xFFF5F5F5);
  static const textDarkSecondary = Color(0xFFB0B0B0);
  static const textDarkTertiary = Color(0xFF71717A);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}
