import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────────────────────────────────────
// IMPORTS (all refactored from previous screens)
// ─────────────────────────────────────────────────────────────────────────────
//
// import 'package:your_app/core/theme/colors.dart';
//
// ── Animations ────────────────────────────────────────────────────────────────
// import 'package:your_app/core/animations/entrance_animation.dart';
//   StaggeredEntranceController — splash → auth → home → elections → candidates → forum
//
// import 'package:your_app/core/animations/shimmer_sweep.dart';
//   ShimmerSweepController — one-shot gold sweep (splash_screen.dart)
//
// import 'package:your_app/core/animations/pulse_controller.dart';
//   PulseController — live dot / badge pulse (home_screen.dart)
//
// import 'package:your_app/core/animations/press_scale.dart';
//   PressScaleController — 1.0→0.97 tap (elections_screen.dart)
//
// import 'package:your_app/core/animations/bounce_scale.dart';
//   BounceScaleController — TweenSequence spring (elections_screen.dart)
//
// import 'package:your_app/core/animations/countdown_tick.dart';
//   CountdownTickController — 1s periodic (elections_screen.dart)
//
// ── Painters ──────────────────────────────────────────────────────────────────
// import 'package:your_app/core/painters/grid_painter.dart';
//   GridPainter — 36px institutional grid (splash_screen.dart)
//
// import 'package:your_app/core/painters/hex_ring_painter.dart';
//   HexRingPainter — concentric hex rings (auth_screens.dart)
//
// import 'package:your_app/core/painters/mini_logo_painter.dart';
//   MiniLogoPainter — hex + circle + check verified seal (auth_screens.dart)
//
// import 'package:your_app/core/painters/radial_glow_painter.dart';
//   RadialGlowPainter — ambient radial glow (candidates_screen.dart)
//
// import 'package:your_app/core/painters/waveform_painter.dart';
//   WaveformPainter — vertical bar chart (candidates_screen.dart)
//
// import 'package:your_app/core/painters/skill_radar_painter.dart';
//   SkillRadarPainter — pentagon radar chart (candidates_screen.dart)
//
// import 'package:your_app/core/painters/heatmap_painter.dart';
//   HeatmapPainter — activity heatmap cells (forum_screen.dart)
//
// import 'package:your_app/core/painters/timer_arc_painter.dart';
//   TimerArcPainter — circular countdown arc (forum_screen.dart)
//
// ── Shared Widgets ────────────────────────────────────────────────────────────
// import 'package:your_app/core/widgets/accent_tag.dart';
// import 'package:your_app/core/widgets/sticky_header_delegate.dart';
// import 'package:your_app/core/widgets/loading_dots.dart';

/// VoteSecure — Profile Screen (Tab 5 / Final Screen)
///
/// The voter's personal civic identity vault.
/// Shows verified identity, voting history, wallet, activity stats,
/// followed candidates, security settings, and ZK proof status.
///
/// Layout:
///   CustomScrollView with SliverList
///   ├── Profile hero header (avatar, name, region, verified badge)
///   ├── Identity verification status strip (Biometric · ZK · Wallet · Region)
///   ├── Voting activity stats row
///   ├── Civic participation waveform chart
///   ├── Voting history list
///   ├── Followed candidates horizontal scroll
///   ├── Wallet & token section
///   ├── Security & settings section
///   └── Sign out (institutional red, deliberate)
///
/// Animation strategy (all refactored from previous screens):
///   _entranceController  → staggered Interval fades (same as all screens)
///   _shimmerController   → one-shot gold sweep (splash_screen.dart)
///   _pulseController     → live/verified indicator dots (home_screen.dart)
///   _heroGlowController  → slow 3s ambient behind avatar (candidates_screen.dart)
///   _settingsController  → expand/collapse settings sections
///
/// Painter strategy:
///   GridPainter           → background grid (splash_screen.dart)
///   HexRingPainter        → corner decor (auth_screens.dart)
///   MiniLogoPainter       → verified seal (auth_screens.dart)
///   RadialGlowPainter     → ambient glow behind avatar (candidates_screen.dart)
///   WaveformPainter       → civic activity chart (candidates_screen.dart)
///   HeatmapPainter        → activity heatmap (forum_screen.dart)
///   _ZKProofCirclePainter → NEW: ZK proof status ring with node dots
///   _VoterIDCardPainter   → NEW: stylised voter ID card with embossed detail
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // ── Entrance (same 1100ms StaggeredEntranceController — all screens) ────────
  late AnimationController _entranceController;

  // ── Shimmer sweep (ShimmerSweepController — splash_screen.dart) ──────────────
  late AnimationController _shimmerController;

  // ── Live pulse (PulseController — home_screen.dart) ──────────────────────────
  late AnimationController _pulseController;

  // ── Hero avatar ambient glow (slow 3s — candidates_screen.dart spotlight) ───
  // ANIMATION_TYPE: same _spotlightController from candidates_screen.dart
  // 3s repeat reverse, drives RadialGlowPainter behind avatar block
  // opacity oscillates 0.1→0.28 for "breathing" authority feel
  late AnimationController _heroGlowController;

  // ── ZK proof ring rotation — continuous slow spin ────────────────────────────
  // ANIMATION_TYPE: Repeating rotation (no reverse) at 8s/revolution
  // drives _ZKProofCirclePainter outer ring spin
  // subtle — institutional, not flashy
  late AnimationController _zkRingController;

  // ── Scroll ────────────────────────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  // ── Expanded settings sections ────────────────────────────────────────────────
  // Each bool drives an AnimatedSize expand/collapse — same as
  // _expanded in _ElectionListCard (elections_screen.dart)
  bool _securityExpanded = false;
  bool _privacyExpanded = false;
  bool _walletExpanded = false;
  bool _notificationsExpanded = false;

  // ── Staggered entrance animations ────────────────────────────────────────────

  // Hero header block
  // ANIMATION_TYPE: FadeTransition + SlideTransition from above
  // Interval(0.0, 0.4) — same as topbar in all previous screens
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _heroScale; // 0.96→1.0 surface-rising

  // Verification strip
  // ANIMATION_TYPE: FadeTransition + SlideTransition, Interval(0.15, 0.5)
  late Animation<double> _verifyFade;
  late Animation<Offset> _verifySlide;

  // Stats row
  // ANIMATION_TYPE: FadeTransition + SlideTransition, Interval(0.25, 0.6)
  late Animation<double> _statsFade;
  late Animation<Offset> _statsSlide;

  // Content sections (history, candidates, wallet, settings)
  // ANIMATION_TYPE: FadeTransition + SlideTransition, Interval(0.4, 0.85)
  // per-section stagger using index * 0.07
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  // Gold shimmer
  late Animation<double> _shimmerPos;

  // Pulse
  late Animation<double> _pulseAnim;

  // Hero ambient glow
  late Animation<double> _heroGlow;

  // ZK ring rotation (0→2π continuous)
  late Animation<double> _zkRotation;

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
  }

  void _buildControllers() {
    // 1100ms entrance — same as every screen
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // One-shot shimmer — splash_screen.dart
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 1600ms repeating pulse — home_screen.dart
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // 3s slow ambient glow — candidates_screen.dart _spotlightController
    _heroGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // 8s slow continuous rotation for ZK ring
    // ANIMATION_TYPE: Tween(0→2π).animate with linear curve, repeat (no reverse)
    // slower than any previous animation — feels like a "processing" or
    // "blockchain syncing" indicator, not a loading spinner
    _zkRingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  void _buildAnimations() {
    // Hero header
    _heroFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _heroSlide = Tween(begin: const Offset(0, -0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    // ANIMATION_TYPE: ScaleTransition 0.96→1.0 — surface-rising entrance
    // same _spotlightScale from candidates_screen.dart
    _heroScale = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Verification strip
    _verifyFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
    );
    _verifySlide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
          ),
        );

    // Stats row
    _statsFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
    );
    _statsSlide = Tween(begin: const Offset(0, 0.14), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );

    // Content sections
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
    );
    _contentSlide = Tween(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
          ),
        );

    // Shimmer — splash_screen.dart
    _shimmerPos = Tween(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Pulse
    _pulseAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Hero glow — same as _spotlightGlow in candidates_screen.dart
    _heroGlow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroGlowController, curve: Curves.easeInOut),
    );

    // ZK ring rotation — Tween(0→2π), linear, continuous
    _zkRotation = Tween(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _zkRingController, curve: Curves.linear));
  }

  Future<void> _runEntrance() async {
    await Future.delayed(const Duration(milliseconds: 60));
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    // ANIMATION_TYPE: same one-shot shimmer as splash_screen.dart
    _shimmerController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _heroGlowController.dispose();
    _zkRingController.dispose();
    _scrollController.dispose();
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
          _heroGlowController,
          _zkRingController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              // PAINTER: GridPainter (splash_screen.dart)
              _buildBackground(),
              Opacity(
                opacity: 0.04,
                child: CustomPaint(
                  size: MediaQuery.of(context).size,
                  // PAINTER: GridPainter — 36px gold institutional grid
                  // same across every screen since splash_screen.dart
                  painter: _GridPainter(color: TColors.secondary),
                ),
              ),

              // PAINTER: HexRingPainter (auth_screens.dart)
              // Top-right decorative concentric hex rings
              Positioned(
                top: -50,
                right: -50,
                child: Opacity(
                  opacity: 0.05,
                  child: CustomPaint(
                    size: const Size(230, 230),
                    // PAINTER: HexRingPainter — 3 rings, gold stroke at 0.5/ring opacity
                    // same corner decoration used in home, elections, candidates, forum
                    painter: _HexRingPainter(),
                  ),
                ),
              ),

              // PAINTER: HexRingPainter — bottom-left second instance
              Positioned(
                bottom: -60,
                left: -60,
                child: Opacity(
                  opacity: 0.04,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _HexRingPainter(),
                  ),
                ),
              ),

              // ANIMATION_TYPE: ShimmerSweep one-shot (splash_screen.dart)
              _buildShimmer(context),

              // Main body
              _buildBody(context),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BACKGROUND
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    final p = (_scrollOffset * 0.00012).clamp(0.0, 0.08);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Subtle parallax shift on scroll — same as candidates + forum
          begin: Alignment(-1 + p, -1),
          end: const Alignment(1, 1),
          colors: const [
            Color(0xFF08100A),
            TColors.darkBackground,
            Color(0xFF0B0A14),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // ANIMATION_TYPE: AnimatedBuilder(_shimmerPos) + Transform.translate
  // identical pattern across every screen (splash → forum)
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
              width: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    TColors.secondary.withOpacity(0.05),
                    TColors.secondary.withOpacity(0.08),
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

  // ─────────────────────────────────────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero profile header
          SliverToBoxAdapter(child: _buildHeroHeader()),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Identity verification strip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildVerificationStrip(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Voter ID card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildVoterIDCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Civic stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStatsRow(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Civic participation waveform
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildActivitySection(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Voting history
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionLabel(
                tag: 'VOTE RECORD',
                title: 'Voting History',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: _VoteHistoryTile(
                  record: _voteHistory[i],
                  index: i,
                  contentAnim: _contentFade,
                  // ANIMATION_TYPE: per-tile stagger Interval(i*0.05, 1.0)
                  // same as elections + candidates + forum card lists
                ),
              ),
              childCount: _voteHistory.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Followed candidates
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionLabel(
                tag: 'FOLLOWING',
                title: 'Tracked Candidates',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildFollowedCandidates()),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Wallet section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildExpandableSection(
                tag: 'WEB3',
                title: 'Wallet & Tokens',
                icon: Icons.account_balance_wallet_outlined,
                isExpanded: _walletExpanded,
                onToggle: () =>
                    setState(() => _walletExpanded = !_walletExpanded),
                child: _buildWalletContent(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Security section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildExpandableSection(
                tag: 'SECURITY',
                title: 'Biometric & Identity',
                icon: Icons.security_outlined,
                isExpanded: _securityExpanded,
                onToggle: () =>
                    setState(() => _securityExpanded = !_securityExpanded),
                child: _buildSecurityContent(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Privacy section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildExpandableSection(
                tag: 'ZK-PROOF',
                title: 'Privacy Settings',
                icon: Icons.shield_outlined,
                isExpanded: _privacyExpanded,
                onToggle: () =>
                    setState(() => _privacyExpanded = !_privacyExpanded),
                child: _buildPrivacyContent(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Notifications section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildExpandableSection(
                tag: 'ALERTS',
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                isExpanded: _notificationsExpanded,
                onToggle: () => setState(
                  () => _notificationsExpanded = !_notificationsExpanded,
                ),
                child: _buildNotificationsContent(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── App version + about
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildAboutRow(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Sign out — deliberate, institutional red
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSignOut(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HERO HEADER
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildHeroHeader() {
    final collapseRatio = (_scrollOffset / 100).clamp(0.0, 1.0);

    // ANIMATION_TYPE: FadeTransition(_heroFade) + SlideTransition(_heroSlide)
    // + ScaleTransition(_heroScale) 0.96→1.0
    // Same tri-animation entrance as spotlight card in candidates_screen.dart
    return FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: ScaleTransition(
          scale: _heroScale,
          child: AnimatedBuilder(
            animation: Listenable.merge([_heroGlow, _pulseAnim]),
            builder: (_, __) => Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B1E14), Color(0xFF0D0D1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: TColors.secondary.withOpacity(
                      0.18 + 0.08 * _heroGlow.value,
                    ),
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // PAINTER: RadialGlowPainter (candidates_screen.dart)
                  // ambient glow behind avatar — opacity driven by _heroGlow
                  // same technique as spotlight card background glow
                  Positioned(
                    left: -20,
                    top: -20,
                    child: CustomPaint(
                      size: const Size(200, 200),
                      // PAINTER: RadialGlowPainter
                      // soft green radial gradient 0.1→0.26 opacity breathing
                      // same _RadialGlowPainter used in candidates_screen.dart
                      painter: _RadialGlowPainter(
                        color: TColors.primary,
                        opacity: 0.10 + 0.16 * _heroGlow.value,
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Avatar with ZK proof ring
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // PAINTER: _ZKProofCirclePainter (NEW this screen)
                              // Outer slowly-rotating dotted ring — 8s revolution
                              // Represents ZK proof sync status
                              // Node dots at cardinal + diagonal positions
                              // Same drawCircle + drawArc as splash_screen.dart logo
                              AnimatedBuilder(
                                animation: _zkRotation,
                                builder: (_, __) => SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CustomPaint(
                                    // PAINTER: _ZKProofCirclePainter (NEW)
                                    // Slow-rotating outer ring: 8 node dots
                                    // ring stroke: TColors.secondary.withOpacity(0.3)
                                    // node dots: TColors.secondary at 0.6 opacity
                                    // rotation driven by _zkRotation (0→2π)
                                    painter: _ZKProofCirclePainter(
                                      rotation: _zkRotation.value,
                                      color: TColors.secondary,
                                    ),
                                  ),
                                ),
                              ),

                              // Avatar circle
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0B3D2E),
                                      Color(0xFF1A1A40),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: TColors.secondary.withOpacity(
                                      0.45 + 0.15 * _pulseAnim.value,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'AO',
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSerif',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: TColors.secondary,
                                    ),
                                  ),
                                ),
                              ),

                              // Verified seal — bottom-right of avatar
                              // PAINTER: MiniLogoPainter (auth_screens.dart)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: TColors.darkBackground,
                                    border: Border.all(
                                      color: TColors.secondary.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: CustomPaint(
                                      // PAINTER: MiniLogoPainter (auth_screens.dart)
                                      // hex + green circle + white check — verified
                                      // same 16×16 instance used across all screens
                                      painter: _MiniLogoPainter(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 18),

                          // Name + region + tags
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Adebayo Okonkwo',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSerif',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: TColors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 12,
                                      color: TColors.textDarkTertiary,
                                    ),
                                    const SizedBox(width: 3),
                                    const Text(
                                      'Benin City · Edo State · Nigeria',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: TColors.textDarkTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  children: const [
                                    _AccentTag(label: 'VERIFIED VOTER'),
                                    _AccentTag(label: 'REGION-LOCKED'),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Edit profile button
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: TColors.darkCard,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: TColors.darkBorder),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: TColors.textDarkTertiary,
                              size: 16,
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

                      const SizedBox(height: 16),

                      // Voter ID mono text
                      Row(
                        children: [
                          const Text(
                            'VOTER ID',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              color: TColors.textDarkTertiary,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // ANIMATION_TYPE: AnimatedSwitcher flicker effect
                          // text occasionally "refreshes" with a crossfade (200ms)
                          // simulates live ZK verification sync — subtle
                          Text(
                            'NG · EDO · 2024 · 7743A',
                            style: TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: TColors.secondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Spacer(),
                          // ZK sync indicator
                          AnimatedBuilder(
                            // ANIMATION_TYPE: AnimatedBuilder(_pulseAnim)
                            // dot pulses green to signal live ZK proof sync
                            // same _LiveDot mechanic from home_screen.dart
                            animation: _pulseAnim,
                            builder: (_, __) => Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: TColors.success,
                                    boxShadow: [
                                      BoxShadow(
                                        color: TColors.success.withOpacity(
                                          0.4 * _pulseAnim.value,
                                        ),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'ZK SYNCED',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: TColors.success,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // VERIFICATION STRIP
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildVerificationStrip() {
    // ANIMATION_TYPE: FadeTransition(_verifyFade) + SlideTransition(_verifySlide)
    return FadeTransition(
      opacity: _verifyFade,
      child: SlideTransition(
        position: _verifySlide,
        child: Row(
          children: [
            Expanded(
              child: _VerifyChip(
                icon: Icons.fingerprint,
                label: 'Biometric',
                status: 'Verified',
                active: true,
                pulseAnim: _pulseAnim,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _VerifyChip(
                icon: Icons.shield_outlined,
                label: 'ZK Proof',
                status: 'Active',
                active: true,
                pulseAnim: _pulseAnim,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _VerifyChip(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet',
                status: 'Linked',
                active: true,
                pulseAnim: _pulseAnim,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _VerifyChip(
                icon: Icons.location_on_outlined,
                label: 'Region',
                status: 'Locked',
                active: true,
                pulseAnim: _pulseAnim,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // VOTER ID CARD
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildVoterIDCard() {
    // ANIMATION_TYPE: FadeTransition(_verifyFade) — shares same interval
    // PAINTER: _VoterIDCardPainter (NEW this screen)
    // Embossed card background pattern
    return FadeTransition(
      opacity: _verifyFade,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) => Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2B1E), Color(0xFF12112A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: TColors.secondary.withOpacity(
                0.28 + 0.1 * _pulseAnim.value,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: TColors.primary.withOpacity(
                  0.25 + 0.1 * _pulseAnim.value,
                ),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // PAINTER: _VoterIDCardPainter (NEW)
              // Embossed card detail: subtle diagonal line pattern
              // + corner hex marks + center seal watermark
              // Same RRect + path primitives as splash_screen.dart logo
              // and candidates_screen.dart _MilestonePainter
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    // PAINTER: _VoterIDCardPainter (NEW this screen)
                    // Draws: diagonal emboss lines (PathMetrics dashes)
                    //        4 corner bracket marks (same as splash logo brackets)
                    //        center watermark hex outline at 6% opacity
                    painter: _VoterIDCardPainter(
                      lineColor: TColors.secondary.withOpacity(0.06),
                      accentColor: TColors.secondary.withOpacity(0.15),
                    ),
                  ),
                ),
              ),

              // Card content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Logo mark
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CustomPaint(
                            // PAINTER: MiniLogoPainter (auth_screens.dart)
                            painter: _MiniLogoPainter(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'VOTESECURE',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSerif',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TColors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        const Spacer(),
                        _AccentTag(label: 'VOTER CARD'),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ADEBAYO OKONKWO',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSerif',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: TColors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'NG · EDO · 2024 · 7743A',
                              style: TextStyle(
                                fontFamily: 'IBMPlexMono',
                                fontSize: 11,
                                color: TColors.secondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Heatmap — 7-day voting activity
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'ACTIVITY',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 8,
                                color: TColors.textDarkTertiary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 56,
                              height: 10,
                              child: CustomPaint(
                                // PAINTER: HeatmapPainter (forum_screen.dart)
                                // 7-cell activity row on the voter ID card
                                // same painter used in forum scoreboard strip
                                painter: _HeatmapPainter(
                                  values: const [
                                    0.3,
                                    1.0,
                                    0.2,
                                    0.8,
                                    0.0,
                                    0.6,
                                    1.0,
                                  ],
                                  activeColor: TColors.secondary,
                                  inactiveColor: TColors.darkBorder,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STATS ROW
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    // ANIMATION_TYPE: FadeTransition(_statsFade) + SlideTransition(_statsSlide)
    // same as home_screen.dart _buildStatsRow
    return FadeTransition(
      opacity: _statsFade,
      child: SlideTransition(
        position: _statsSlide,
        child: Row(
          children: const [
            Expanded(
              child: _ProfileStatChip(
                value: '2',
                label: 'Votes\nCast',
                icon: Icons.how_to_vote_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _ProfileStatChip(
                value: '12',
                label: 'Candidates\nFollowed',
                icon: Icons.person_search_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _ProfileStatChip(
                value: '6',
                label: 'Questions\nAsked',
                icon: Icons.forum_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _ProfileStatChip(
                value: '98%',
                label: 'Civic\nScore',
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ACTIVITY SECTION (waveform chart)
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildActivitySection() {
    // ANIMATION_TYPE: FadeTransition(_contentFade)
    return FadeTransition(
      opacity: _contentFade,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AccentTag(label: 'CIVIC ACTIVITY'),
                const Spacer(),
                Text(
                  'Last 12 elections',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: TColors.textDarkTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // PAINTER: WaveformPainter (candidates_screen.dart)
            // Vertical bar chart showing participation rate across elections
            // Same painter as candidate approval history in profile tab
            SizedBox(
              height: 56,
              child: CustomPaint(
                // PAINTER: WaveformPainter (candidates_screen.dart)
                // Bar heights = participation percentage per election
                // active: TColors.secondary gradient
                // inactive: TColors.darkBorder
                painter: _WaveformPainter(
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
                  inactiveColor: TColors.darkBorder,
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
                    color: TColors.textDarkTertiary,
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

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel({required String tag, required String title}) {
    // ANIMATION_TYPE: FadeTransition(_contentFade)
    return FadeTransition(
      opacity: _contentFade,
      child: Row(
        children: [
          _AccentTag(label: tag),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: TColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // FOLLOWED CANDIDATES
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFollowedCandidates() {
    // ANIMATION_TYPE: FadeTransition(_contentFade)
    // Horizontal scroll — same layout as election cards in home_screen.dart
    return FadeTransition(
      opacity: _contentFade,
      child: SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _followedCandidates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final c = _followedCandidates[i];
            return Container(
              width: 130,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0B3D2E), Color(0xFF1A1A40)],
                          ),
                          border: Border.all(
                            color: TColors.secondary.withOpacity(0.4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            c.initials,
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSerif',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: TColors.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // PAINTER: MiniLogoPainter (auth_screens.dart)
                      // tiny verified seal beside avatar
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CustomPaint(painter: _MiniLogoPainter()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: TColors.textDarkPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: c.partyColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: c.partyColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      c.partyCode,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: c.partyColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // EXPANDABLE SECTION
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildExpandableSection({
    required String tag,
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    // ANIMATION_TYPE: FadeTransition(_contentFade)
    // Expand/collapse: AnimatedSize — same as election card expand in elections_screen.dart
    // Chevron: AnimatedRotation 0→0.5 turns — same as chevron in elections_screen.dart
    return FadeTransition(
      opacity: _contentFade,
      child: Container(
        decoration: BoxDecoration(
          color: TColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.darkBorder),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: TColors.secondary, size: 18),
                    const SizedBox(width: 12),
                    _AccentTag(label: tag),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSerif',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: TColors.white,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      // ANIMATION_TYPE: AnimatedRotation 0→0.5 turns
                      // chevron spins 180° on expand — same as elections_screen.dart
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: TColors.textDarkTertiary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ANIMATION_TYPE: AnimatedSize height 0→content
            // Curves.easeOut 300ms — same as election card expand
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: isExpanded
                  ? Column(
                      children: [
                        Divider(height: 1, color: TColors.darkBorder),
                        child,
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // EXPANDABLE SECTION CONTENTS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildWalletContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          _WalletRow(
            label: 'Connected Wallet',
            value: '0x7f4a...3e12',
            icon: Icons.account_balance_wallet_outlined,
            mono: true,
          ),
          const SizedBox(height: 12),
          _WalletRow(
            label: 'USDT Balance',
            value: '\$24.50',
            icon: Icons.toll_outlined,
          ),
          const SizedBox(height: 12),
          _WalletRow(
            label: 'Votes Paid For',
            value: '2 transactions',
            icon: Icons.receipt_outlined,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: TColors.darkElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TColors.darkBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.open_in_new_rounded,
                  color: TColors.secondary,
                  size: 14,
                ),
                SizedBox(width: 8),
                Text(
                  'View on Blockchain Explorer',
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
      ),
    );
  }

  Widget _buildSecurityContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          _SecurityToggleRow(
            label: 'Biometric Login',
            subtitle: 'Fingerprint or Face ID required',
            icon: Icons.fingerprint,
            enabled: true,
            // ANIMATION_TYPE: AnimatedContainer toggle — same as _FollowButton
          ),
          const _DividerLine(),
          _SecurityToggleRow(
            label: 'Device Binding',
            subtitle: 'This device is the only trusted device',
            icon: Icons.phone_android_outlined,
            enabled: true,
          ),
          const _DividerLine(),
          _SecurityToggleRow(
            label: 'Government DB Sync',
            subtitle: 'Identity verified against NIMC database',
            icon: Icons.verified_user_outlined,
            enabled: true,
          ),
          const _DividerLine(),
          _SecurityToggleRow(
            label: 'Live Face Check',
            subtitle: 'Required before each vote is cast',
            icon: Icons.face_outlined,
            enabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ZK Proof status with ring painter
          Row(
            children: [
              AnimatedBuilder(
                animation: _zkRotation,
                builder: (_, __) => SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomPaint(
                    // PAINTER: _ZKProofCirclePainter (NEW this screen)
                    // smaller 48×48 version in privacy section
                    // same rotating ring, same painter instance
                    painter: _ZKProofCirclePainter(
                      rotation: _zkRotation.value,
                      color: TColors.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ZK Proof Active',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSerif',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: TColors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Your vote is private. Your identity is proven '
                      'without being exposed.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: TColors.textDarkTertiary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _DividerLine(),
          _SecurityToggleRow(
            label: 'Anonymous Vote Mode',
            subtitle: 'Hide vote from public ledger (ZK enabled)',
            icon: Icons.visibility_off_outlined,
            enabled: true,
          ),
          const _DividerLine(),
          _SecurityToggleRow(
            label: 'Share Civic Score',
            subtitle: 'Allow others to see your participation rate',
            icon: Icons.public_outlined,
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          _SecurityToggleRow(
            label: 'Election Reminders',
            subtitle: '24h before elections in your region',
            icon: Icons.notifications_active_outlined,
            enabled: true,
          ),
          const _DividerLine(),
          _SecurityToggleRow(
            label: 'Candidate Answers',
            subtitle: 'When a candidate responds to your question',
            icon: Icons.comment_outlined,
            enabled: true,
          ),
          const _DividerLine(),
          _SecurityToggleRow(
            label: 'Results Alerts',
            subtitle: 'When elections you voted in conclude',
            icon: Icons.bar_chart_rounded,
            enabled: true,
          ),
          const _DividerLine(),
          _SecurityToggleRow(
            label: 'Fraud Alerts',
            subtitle: 'AI-detected anomalies in your region',
            icon: Icons.warning_amber_outlined,
            enabled: false,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ABOUT ROW
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildAboutRow() {
    return FadeTransition(
      opacity: _contentFade,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // PAINTER: MiniLogoPainter (auth_screens.dart)
          SizedBox(
            width: 18,
            height: 18,
            child: CustomPaint(painter: _MiniLogoPainter()),
          ),
          const SizedBox(width: 8),
          Text(
            'VoteSecure v1.0.0',
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 11,
              color: TColors.textDarkTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 16),
          Text('·', style: TextStyle(color: TColors.darkBorder, fontSize: 14)),
          const SizedBox(width: 16),
          Text(
            'Terms',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: TColors.textDarkTertiary,
            ),
          ),
          const SizedBox(width: 16),
          Text('·', style: TextStyle(color: TColors.darkBorder, fontSize: 14)),
          const SizedBox(width: 16),
          Text(
            'Privacy',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: TColors.textDarkTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SIGN OUT
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSignOut() {
    // ANIMATION_TYPE: FadeTransition(_contentFade)
    // Button itself: PressScaleController 1.0→0.97 on tap — same as all cards
    // Deliberate — no pulse, no glow. Institutional gravity.
    return FadeTransition(opacity: _contentFade, child: _SignOutButton());
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VOTE HISTORY TILE
// ═════════════════════════════════════════════════════════════════════════════

class _VoteHistoryTile extends StatelessWidget {
  final _VoteRecord record;
  final int index;
  final Animation<double> contentAnim;

  const _VoteHistoryTile({
    required this.record,
    required this.index,
    required this.contentAnim,
  });

  @override
  Widget build(BuildContext context) {
    // ANIMATION_TYPE: per-tile FadeTransition with Interval(index*0.05, 1.0)
    // same stagger as elections + candidates + forum cards
    final stagger = CurvedAnimation(
      parent: contentAnim,
      curve: Interval(
        (index * 0.05).clamp(0.0, 0.6),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: stagger,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: TColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.darkBorder),
        ),
        child: Row(
          children: [
            // Date block — same as upcoming elections in home_screen.dart
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TColors.secondary.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    record.month,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: TColors.secondary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    record.day,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSerif',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TColors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.election,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSerif',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    record.region,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: TColors.textDarkTertiary,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // On-chain verified badge
                Row(
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 11,
                      color: TColors.success,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'On-chain',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: TColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _AccentTag(label: record.level),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ATOMIC SUBWIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _VerifyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final bool active;
  final Animation<double> pulseAnim;

  const _VerifyChip({
    required this.icon,
    required this.label,
    required this.status,
    required this.active,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // ANIMATION_TYPE: AnimatedBuilder(_pulseAnim)
      // active chips get a subtle glow pulse on border — same as
      // status pills in home_screen.dart identity card
      animation: pulseAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: active ? TColors.success.withOpacity(0.06) : TColors.darkCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? TColors.success.withOpacity(0.25 + 0.12 * pulseAnim.value)
                : TColors.darkBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? TColors.success : TColors.textDarkTertiary,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: TColors.textDarkTertiary,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: active ? TColors.success : TColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _ProfileStatChip({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: TColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TColors.secondary, size: 15),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: TColors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9.5,
              color: TColors.textDarkTertiary,
              height: 1.4,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool mono;

  const _WalletRow({
    required this.label,
    required this.value,
    required this.icon,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: TColors.textDarkTertiary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: TColors.textDarkSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: mono ? 'IBMPlexMono' : 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: TColors.textDarkPrimary,
            letterSpacing: mono ? 0.8 : 0,
          ),
        ),
      ],
    );
  }
}

class _SecurityToggleRow extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool enabled;

  const _SecurityToggleRow({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.enabled,
  });

  @override
  State<_SecurityToggleRow> createState() => _SecurityToggleRowState();
}

class _SecurityToggleRowState extends State<_SecurityToggleRow> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            widget.icon,
            size: 16,
            color: _enabled ? TColors.secondary : TColors.textDarkTertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: TColors.textDarkPrimary,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5,
                    color: TColors.textDarkTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // ANIMATION_TYPE: AnimatedContainer color shift on toggle
          // green track → dark track — same pattern as _FollowButton
          // Curves.easeOut 200ms
          GestureDetector(
            onTap: () => setState(() => _enabled = !_enabled),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 24,
              decoration: BoxDecoration(
                color: _enabled ? TColors.primary : TColors.darkElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _enabled
                      ? TColors.secondary.withOpacity(0.4)
                      : TColors.darkBorder,
                ),
              ),
              child: AnimatedAlign(
                // ANIMATION_TYPE: AnimatedAlign moves thumb left↔right
                // same 200ms easing as container color shift
                duration: const Duration(milliseconds: 200),
                alignment: _enabled
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _enabled
                        ? TColors.secondary
                        : TColors.textDarkTertiary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: TColors.darkBorder.withOpacity(0.5));
  }
}

class _SignOutButton extends StatefulWidget {
  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton>
    with SingleTickerProviderStateMixin {
  // ANIMATION_TYPE: PressScaleController 1.0→0.97 on tap
  // same as every card press in elections + candidates + forum
  late AnimationController _pressCtrl;

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
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (_, __) => Transform.scale(
          scale: _pressCtrl.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TColors.error.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout_rounded, color: TColors.error, size: 17),
                SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.error,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Accent tag — same as all previous screens
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

// ═════════════════════════════════════════════════════════════════════════════
// PAINTERS — NEW (this screen)
// ═════════════════════════════════════════════════════════════════════════════

/// _ZKProofCirclePainter — Slowly-rotating ZK proof status ring
/// NEW to this screen.
/// Draws a dashed outer ring with 8 node dots that slowly rotate.
/// Represents blockchain/ZK proof synchronisation status.
/// rotation: 0→2π driven by _zkRingController (8s/revolution)
/// Ring: dashed stroke — PathMetrics technique from _MilestonePainter (candidates_screen.dart)
/// Node dots: drawCircle at 8 equidistant angles — same as splash_screen.dart logo vertex dots
/// Inner ring: thin solid circle at 0.65× radius
class _ZKProofCirclePainter extends CustomPainter {
  final double rotation; // 0.0→2π
  final Color color;

  const _ZKProofCirclePainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = math.min(size.width, size.height) / 2 - 2;
    final innerR = outerR * 0.65;

    // Outer dashed ring (rotating)
    // PAINTER: same dashed-line PathMetrics technique as _MilestonePainter
    _drawDashedCircle(
      canvas,
      center,
      outerR,
      color.withOpacity(0.28),
      3.5,
      2.5,
      1.0,
    );

    // Inner solid ring (static)
    canvas.drawCircle(
      center,
      innerR,
      Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 8 rotating node dots
    // PAINTER: drawCircle at equidistant angles — same as
    // splash_screen.dart logo vertex dots and candidates_screen.dart radar dots
    const nodeCount = 8;
    for (int i = 0; i < nodeCount; i++) {
      final angle = rotation + (2 * math.pi / nodeCount) * i;
      final nx = center.dx + outerR * math.cos(angle);
      final ny = center.dy + outerR * math.sin(angle);

      // Alternate between larger and smaller dots
      final isMain = i % 2 == 0;
      canvas.drawCircle(
        Offset(nx, ny),
        isMain ? 2.8 : 1.6,
        Paint()..color = color.withOpacity(isMain ? 0.7 : 0.35),
      );
    }

    // Center small dot — anchor point
    canvas.drawCircle(center, 2.5, Paint()..color = color.withOpacity(0.5));
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double dashLen,
    double gapLen,
    double strokeWidth,
  ) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final dashPath = Path();
    var dist = 0.0;
    bool drawing = true;

    for (final metric in path.computeMetrics()) {
      dist = 0.0;
      drawing = true;
      while (dist < metric.length) {
        final seg = drawing ? dashLen : gapLen;
        final end = math.min(dist + seg, metric.length);
        if (drawing) {
          final t1 = metric.getTangentForOffset(dist)!.position;
          final t2 = metric.getTangentForOffset(end)!.position;
          dashPath.moveTo(t1.dx, t1.dy);
          dashPath.lineTo(t2.dx, t2.dy);
        }
        dist += seg;
        drawing = !drawing;
      }
    }

    canvas.drawPath(
      dashPath,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ZKProofCirclePainter old) =>
      old.rotation != rotation;
}

/// _VoterIDCardPainter — Embossed card background detail
/// NEW to this screen.
/// Adds institutional texture to the voter ID card:
///   1. Diagonal dashed lines (subtle, 6% opacity) — like a security watermark
///   2. Four corner bracket marks — same technique as splash_screen.dart logo brackets
///   3. Center hex watermark outline — same HexRingPainter geometry
/// All primitives reuse techniques established in previous painters.
class _VoterIDCardPainter extends CustomPainter {
  final Color lineColor;
  final Color accentColor;

  const _VoterIDCardPainter({
    required this.lineColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8;

    // Diagonal lines (every 20px) — security watermark texture
    // Same diagonal technique as GridPainter but at 45° angle
    const step = 20.0;
    for (double d = -size.height; d < size.width + size.height; d += step) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        linePaint,
      );
    }

    // Corner brackets — same as splash_screen.dart _IdentityIllustration brackets
    final bracketPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square;

    const bl = 12.0; // bracket length
    const bp = 8.0; // bracket padding from corner
    // Top-left
    canvas.drawLine(Offset(bp, bp), Offset(bp + bl, bp), bracketPaint);
    canvas.drawLine(Offset(bp, bp), Offset(bp, bp + bl), bracketPaint);
    // Top-right
    canvas.drawLine(
      Offset(size.width - bp, bp),
      Offset(size.width - bp - bl, bp),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - bp, bp),
      Offset(size.width - bp, bp + bl),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(bp, size.height - bp),
      Offset(bp + bl, size.height - bp),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(bp, size.height - bp),
      Offset(bp, size.height - bp - bl),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(size.width - bp, size.height - bp),
      Offset(size.width - bp - bl, size.height - bp),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - bp, size.height - bp),
      Offset(size.width - bp, size.height - bp - bl),
      bracketPaint,
    );

    // Center hex watermark — same geometry as HexRingPainter (auth_screens.dart)
    final hexCenter = Offset(size.width * 0.82, size.height / 2);
    const hexR = 28.0;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = hexCenter.dx + hexR * math.cos(angle);
      final y = hexCenter.dy + hexR * math.sin(angle);
      if (i == 0)
        hexPath.moveTo(x, y);
      else
        hexPath.lineTo(x, y);
    }
    hexPath.close();
    canvas.drawPath(
      hexPath,
      Paint()
        ..color = accentColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant _VoterIDCardPainter old) => false;
}

// ── Refactored painters (same instances across all screens) ────────────────

class _HexRingPainter extends CustomPainter {
  // PAINTER: HexRingPainter (auth_screens.dart)
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (int ring = 1; ring <= 3; ring++) {
      final r = size.width * 0.15 * ring;
      final p = Path();
      for (int i = 0; i < 6; i++) {
        final a = (math.pi / 3) * i - math.pi / 6;
        final x = c.dx + r * math.cos(a);
        final y = c.dy + r * math.sin(a);
        if (i == 0)
          p.moveTo(x, y);
        else
          p.lineTo(x, y);
      }
      p.close();
      canvas.drawPath(
        p,
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

class _MiniLogoPainter extends CustomPainter {
  // PAINTER: MiniLogoPainter (auth_screens.dart)
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final a = (math.pi / 3) * i - math.pi / 6;
      if (i == 0)
        hexPath.moveTo(
          c.dx + r * 0.9 * math.cos(a),
          c.dy + r * 0.9 * math.sin(a),
        );
      else
        hexPath.lineTo(
          c.dx + r * 0.9 * math.cos(a),
          c.dy + r * 0.9 * math.sin(a),
        );
    }
    hexPath.close();
    canvas.drawPath(
      hexPath,
      Paint()
        ..color = TColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(c, r * 0.55, Paint()..color = TColors.primary);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.22, c.dy)
        ..lineTo(c.dx - r * 0.04, c.dy + r * 0.18)
        ..lineTo(c.dx + r * 0.24, c.dy - r * 0.2),
      Paint()
        ..color = TColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  // PAINTER: GridPainter (splash_screen.dart)
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const s = 36.0;
    for (double x = 0; x <= size.width; x += s)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y <= size.height; y += s)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RadialGlowPainter extends CustomPainter {
  // PAINTER: RadialGlowPainter (candidates_screen.dart)
  final Color color;
  final double opacity;

  const _RadialGlowPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    canvas.drawCircle(
      center,
      size.width * 0.7,
      Paint()
        ..shader =
            RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.width * 0.7),
            ),
    );
  }

  @override
  bool shouldRepaint(covariant _RadialGlowPainter old) =>
      old.opacity != opacity;
}

class _WaveformPainter extends CustomPainter {
  // PAINTER: WaveformPainter (candidates_screen.dart)
  final List<double> values;
  final Color activeColor;
  final Color inactiveColor;

  const _WaveformPainter({
    required this.values,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final barW = (size.width / values.length) * 0.55;
    final gap = size.width / values.length;

    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      final barH = size.height * v;
      final x = i * gap + (gap - barW) / 2;
      final y = size.height - barH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, barH),
          const Radius.circular(2),
        ),
        Paint()
          ..color = Color.lerp(
            inactiveColor,
            activeColor,
            v,
          )!.withOpacity(0.7 + 0.3 * v),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) => old.values != values;
}

class _HeatmapPainter extends CustomPainter {
  // PAINTER: HeatmapPainter (forum_screen.dart)
  final List<double> values;
  final Color activeColor;
  final Color inactiveColor;

  const _HeatmapPainter({
    required this.values,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final cellSize = size.width / values.length;
    final padding = cellSize * 0.15;

    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * cellSize + padding,
            padding,
            cellSize - padding * 2,
            size.height - padding * 2,
          ),
          const Radius.circular(2),
        ),
        Paint()
          ..color = v > 0
              ? activeColor.withOpacity(0.15 + 0.75 * v)
              : inactiveColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) => old.values != values;
}

// ═════════════════════════════════════════════════════════════════════════════
// STICKY HEADER DELEGATE (same as all previous screens)
// ═════════════════════════════════════════════════════════════════════════════

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
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(_StickyHeaderDelegate old) =>
      maxHeight != old.maxHeight ||
      minHeight != old.minHeight ||
      child != old.child;
}

// ═════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═════════════════════════════════════════════════════════════════════════════

class _VoteRecord {
  final String election;
  final String region;
  final String level;
  final String month;
  final String day;
  final String txHash;

  const _VoteRecord({
    required this.election,
    required this.region,
    required this.level,
    required this.month,
    required this.day,
    required this.txHash,
  });
}

class _FollowedCandidate {
  final String name;
  final String initials;
  final String partyCode;
  final Color partyColor;

  const _FollowedCandidate({
    required this.name,
    required this.initials,
    required this.partyCode,
    required this.partyColor,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// MOCK DATA
// ═════════════════════════════════════════════════════════════════════════════

const List<_VoteRecord> _voteHistory = [
  _VoteRecord(
    election: 'Edo State Gubernatorial Election 2024',
    region: 'Benin City · Edo State',
    level: 'STATE',
    month: 'NOV',
    day: '16',
    txHash: '0x7f4a3e12...',
  ),
  _VoteRecord(
    election: 'University of Benin Student Union',
    region: 'Ugbowo Campus · NG',
    level: 'CAMPUS',
    month: 'SEP',
    day: '04',
    txHash: '0x2d1b9c44...',
  ),
  _VoteRecord(
    election: 'Lagos LGA Chairman — Ikeja',
    region: 'Ikeja · Lagos State',
    level: 'LOCAL',
    month: 'JUL',
    day: '22',
    txHash: '0x5a8f7e01...',
  ),
];

final List<_FollowedCandidate> _followedCandidates = [
  const _FollowedCandidate(
    name: 'Monday Okpebholo',
    initials: 'MO',
    partyCode: 'APC',
    partyColor: Color(0xFF10B981),
  ),
  const _FollowedCandidate(
    name: 'Asue Ighodalo',
    initials: 'AI',
    partyCode: 'PDP',
    partyColor: Color(0xFF3B82F6),
  ),
  const _FollowedCandidate(
    name: 'Dr. Aisha Bukar',
    initials: 'AB',
    partyCode: 'NNPP',
    partyColor: Color(0xFFF59E0B),
  ),
  const _FollowedCandidate(
    name: 'Olumide Akpata',
    initials: 'OA',
    partyCode: 'LP',
    partyColor: Color(0xFFEF4444),
  ),
];

// ── Color shim — remove when importing colors.dart ────────────────────────
class TColors {
  static const primary = Color(0xFF0B3D2E);
  static const secondary = Color(0xFFC6A75E);
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
}
