import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';

import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

// ── Extracted widgets ─────────────────────────────────────────
import 'widgets/home/top_bar.dart';
import 'widgets/home/identity_card.dart';
import 'widgets/home/stats_row.dart';
import 'widgets/home/painters.dart';
import 'widgets/home/section_label.dart';
import 'widgets/home/quick_action_tile.dart';
import 'widgets/home/election_card.dart';
import 'widgets/home/upcoming_election_tile.dart';
import 'widgets/home/global_feed_tile.dart';
import 'widgets/home/forum_question_tile.dart';
import 'widgets/home/data_models.dart';

/// VoteSecure Home Screen
/// The civic command center — all active elections, user identity status,
/// live global map feed, and quick-action vault.
///
/// Animation strategy:
///   All entrance animations reuse the staggered Interval pattern
///   established in splash/onboarding/auth. Comments mark each slot.
///
/// Layout:
///   CustomScrollView → SliverAppBar (collapsing) + SliverList body
///   Bottom nav: 5 tabs — Home · Elections · Candidates · Forum · Profile
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── Entrance controller (same pattern as auth_screens.dart) ─
  late AnimationController _entranceController;

  // ── Shimmer sweep (same as splash_screen.dart) ───────────────
  late AnimationController _shimmerController;

  // ── Live pulse for status badges ─────────────────────────────
  late AnimationController _pulseController;

  // ── Scroll-driven parallax / header collapse ─────────────────
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  // ── HomeScreen entrance animation bundle ──
  late HomeScreenEntranceAnimations _animations;

  @override
  void initState() {
    super.initState();
    _buildControllers();
    _animations = HomeScreenEntranceAnimations(
      entranceController: _entranceController,
      shimmerController: _shimmerController,
      pulseController: _pulseController,
    );
    _runEntrance();

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  void _buildControllers() {
    // ANIMATION_SLOT_1: Main entrance — 1100ms, same duration as auth_screens.dart
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // ANIMATION_SLOT_2: One-shot gold shimmer sweep (from splash_screen.dart)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // ANIMATION_SLOT_3: Repeating pulse for live status indicators
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  Future<void> _runEntrance() async {
    await Future.delayed(const Duration(milliseconds: 60));
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _shimmerController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
    return Scaffold(
      backgroundColor: isDark
          ? TColors.darkBackground
          : TColors.lightBackground,
      body: Stack(
        children: [
          _buildBackground(isDark),
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: GridPainter(
              color: TColors.secondary.withOpacity(isDark ? 0.04 : 0.08),
            ),
          ),
          _buildCornerDecor(isDark),
          _buildBody(isDark),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // BACKGROUND
  // ──────────────────────────────────────────────────────────

  Widget _buildBackground(bool isDark) {
    final parallaxShift = (_scrollOffset * 0.0003).clamp(0.0, 0.2);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + parallaxShift, -1),
          end: const Alignment(1, 1),
          colors: isDark
              ? [
                  const Color(0xFF0B1A12),
                  TColors.darkBackground,
                  const Color(0xFF0A0A16),
                ]
              : [
                  const Color(0xFFE8F0ED),
                  TColors.lightBackground,
                  const Color(0xFFECECF4),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildCornerDecor(bool isDark) {
    return Positioned(
      top: -80,
      right: -80,
      child: Opacity(
        opacity: isDark ? 0.06 : 0.12,
        child: CustomPaint(
          size: const Size(280, 280),
          painter: HexRingPainter(
            color: isDark
                ? TColors.secondary
                : TColors.primary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // MAIN BODY
  // ──────────────────────────────────────────────────────────

  Widget _buildBody(bool isDark) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Top bar (collapses on scroll)
          SliverToBoxAdapter(child: _buildTopBar()),

          // ── Voter identity card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildIdentityCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Quick stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStatsRow(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildQuickActions(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Active elections section label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionLabel(
                tag: 'LIVE NOW',
                title: 'Active Elections',
                trailing: 'View All',
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // ── Horizontal election cards
          SliverToBoxAdapter(child: _buildElectionCardsRow()),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Upcoming elections list
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionLabel(
                tag: 'SCHEDULED',
                title: 'Upcoming',
                trailing: 'Calendar',
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // ── Upcoming cards (vertical list)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: UpcomingElectionTile(
                  index: i,
                  entranceAnim: _animations.cardsFade,
                ),
              ),
              childCount: upcomingElections.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Global feed strip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionLabel(
                tag: 'WORLDWIDE',
                title: 'Global Transparency Feed',
                trailing: 'Map View',
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          SliverToBoxAdapter(child: _buildGlobalFeed()),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Forum activity strip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionLabel(
                tag: 'PUBLIC Q&A',
                title: 'Candidate Forum',
                trailing: 'Join',
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildForumStrip(),
            ),
          ),

          // Bottom padding for floating nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // TOP BAR
  // ──────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    final double collapse = (_scrollOffset / 80).clamp(0.0, 1.0);
    return HomeTopBar(
      fade: _animations.headerFade,
      slide: _animations.headerSlide,
      collapse: collapse,
      pulseAnim: _animations.pulseAnim,
      onNotificationTap: () {},
    );
  }

  // ──────────────────────────────────────────────────────────
  // VOTER IDENTITY CARD
  // ──────────────────────────────────────────────────────────

  Widget _buildIdentityCard() {
    return HomeIdentityCard(
      fade: _animations.identityCardFade,
      slide: _animations.identityCardSlide,
      pulseAnim: _animations.pulseAnim,
    );
  }

  // ──────────────────────────────────────────────────────────
  // STATS ROW
  // ──────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return HomeStatsRow(
      fade: _animations.statsRowFade,
      slide: _animations.statsRowSlide,
    );
  }

  // ──────────────────────────────────────────────────────────
  // QUICK ACTIONS
  // ──────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final isDark = THelperFunctions.isDarkMode(context);
    final tileColor = isDark ? TColors.darkCard : TColors.lightCard;
    final tileBorder = isDark ? TColors.darkBorder : TColors.lightBorder;
    return FadeTransition(
      opacity: _animations.statsRowFade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(tag: 'QUICK ACCESS', title: '', trailing: ''),
          const SizedBox(height: 12),
          Row(
            children: [
              QuickActionTile(
                icon: Icons.how_to_vote_outlined,
                label: 'Vote Now',
                color: TColors.primary,
                borderColor: TColors.secondary,
              ),
              const SizedBox(width: 10),
              QuickActionTile(
                icon: Icons.bar_chart_rounded,
                label: 'Results',
                color: tileColor,
                borderColor: tileBorder,
              ),
              const SizedBox(width: 10),
              QuickActionTile(
                icon: Icons.language_rounded,
                label: 'Global Map',
                color: tileColor,
                borderColor: tileBorder,
              ),
              const SizedBox(width: 10),
              QuickActionTile(
                icon: Icons.forum_outlined,
                label: 'Forum',
                color: tileColor,
                borderColor: tileBorder,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // SECTION LABEL HELPER
  // ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel({
    required String tag,
    required String title,
    required String trailing,
  }) {
    return FadeTransition(
      opacity: _animations.sectionFade,
      child: SectionLabel(tag: tag, title: title, trailing: trailing),
    );
  }

  // ──────────────────────────────────────────────────────────
  // ELECTION CARDS (horizontal scroll)
  // ──────────────────────────────────────────────────────────

  Widget _buildElectionCardsRow() {
    return FadeTransition(
      opacity: _animations.cardsFade,
      child: SlideTransition(
        position: _animations.cardsSlide,
        child: SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: activeElections.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) => ElectionCard(data: activeElections[i]),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // GLOBAL TRANSPARENCY FEED
  // ──────────────────────────────────────────────────────────

  Widget _buildGlobalFeed() {
    return FadeTransition(
      opacity: _animations.globalFade,
      child: SlideTransition(
        position: _animations.globalSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: globalFeedItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlobalFeedTile(
                  item: item,
                  pulseAnim: _animations.pulseAnim,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // FORUM STRIP
  // ──────────────────────────────────────────────────────────

  Widget _buildForumStrip() {
    return FadeTransition(
      opacity: _animations.globalFade,
      child: Column(
        children: forumQuestions.map((q) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ForumQuestionTile(data: q),
          );
        }).toList(),
      ),
    );
  }
}
