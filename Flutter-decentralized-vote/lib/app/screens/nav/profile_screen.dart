import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ProfileScreen
//  Last tab in the bottom nav — civic identity hub for the authenticated voter.
//
//  Sections (top → bottom):
//    1. Collapsing header — avatar · name · verified badge · voter ID chip
//    2. Identity integrity band — biometric, wallet, region lock, ZK status
//    3. Voting activity stats — votes cast, elections participated, streak
//    4. Connected wallet card — address, USDT balance, last deduction
//    5. Voting history list — past elections with on-chain receipt link
//    6. Settings & preferences group
//    7. Danger zone — logout · revoke identity
//
//  Animation strategy: identical Interval stagger pattern used across the app.
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool get isDark => THelperFunctions.isDarkMode(context);

  // ── Controllers ──────────────────────────────────────────────
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  late _ProfileScreenAnimations _anims;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  // ── Local state ───────────────────────────────────────────────
  bool _notificationsOn = true;
  bool _biometricLock = true;
  bool _anonymousMode = false;

  @override
  void initState() {
    super.initState();
    _buildControllers();
    _anims = _ProfileScreenAnimations(
      entranceController: _entranceController,
      shimmerController: _shimmerController,
      pulseController: _pulseController,
    );
    _runEntrance();
    _scrollController.addListener(
      () => setState(() => _scrollOffset = _scrollController.offset),
    );
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

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
        builder: (context, _) => Stack(
          children: [
            _buildBackground(),

            // Subtle grid overlay
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: AuthGridPainter(
                color: TColors.secondary.withOpacity(isDark ? 0.04 : 0.08),
              ),
            ),

            // Corner hex ring (top-right)
            Positioned(
              top: -55,
              right: -55,
              child: Opacity(
                opacity: 0.055,
                child: CustomPaint(
                  size: const Size(240, 240),
                  painter: HexRingPainter(),
                ),
              ),
            ),

            // Gold shimmer sweep
            _buildShimmer(),

            // Main scrollable body
            _buildBody(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BACKGROUND
  // ─────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    final p = (_scrollOffset * 0.00018).clamp(0.0, 0.12);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + p, -1),
          end: const Alignment(1, 1),
          colors: isDark
              ? const [
                  Color(0xFF0B1A12),
                  TColors.darkBackground,
                  Color(0xFF0A0A16),
                ]
              : const [
                  Color(0xFFE8F0ED),
                  TColors.lightBackground,
                  Color(0xFFECECF4),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.025,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (_, __) {
            final pos = Tween(begin: -0.3, end: 1.3)
                .animate(
                  CurvedAnimation(
                    parent: _shimmerController,
                    curve: Curves.easeInOut,
                  ),
                )
                .value;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(pos - 0.4, -1),
                  end: Alignment(pos + 0.4, 1),
                  colors: [
                    Colors.transparent,
                    TColors.secondary.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. Header
          SliverToBoxAdapter(child: _buildHeader()),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── 2. Identity integrity band
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildIdentityBand(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── 3. Voting activity stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildActivityStats(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── 4. Connected wallet card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildWalletCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── 5. Voting history
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSectionLabel(
                tag: 'ON-CHAIN',
                title: 'Voting History',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                child: _buildHistoryTile(_votingHistory[i]),
              ),
              childCount: _votingHistory.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── 6. Settings group
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSectionLabel(tag: 'PREFERENCES', title: 'Settings'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSettingsGroup(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── 7. Danger zone
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDangerZone(),
            ),
          ),

          // Bottom clearance for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. HEADER — avatar · name · verified badge · voter ID chip
  // ─────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final collapse = (_scrollOffset / 80).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: _anims.headerFade,
      child: SlideTransition(
        position: _anims.headerSlide,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            lerpDouble(28, 14, collapse)!,
          ),
          child: Column(
            children: [
              // Top row: title + edit button
              Row(
                children: [
                  Text(
                    'My Profile',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: isDark
                          ? TColors.textDarkPrimary
                          : TColors.textLightPrimary,
                    ),
                  ),
                  const Spacer(),
                  _IconBtn(
                    icon: Icons.edit_outlined,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: Icons.settings_outlined,
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Avatar + verification ring
              Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse ring
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Container(
                      width: 96 + (_anims.pulseAnim.value * 8),
                      height: 96 + (_anims.pulseAnim.value * 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TColors.secondary.withOpacity(
                            0.35 - (_anims.pulseAnim.value * 0.15),
                          ),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  // Gold ring
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          TColors.secondary,
                          TColors.primary,
                          TColors.secondary,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? TColors.darkCard : TColors.lightCard,
                      ),
                      padding: const EdgeInsets.all(3),
                      child: ClipOval(
                        child: Container(
                          color: TColors.primary.withOpacity(0.15),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 38,
                              color: TColors.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Verified badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TColors.primary,
                        border: Border.all(
                          color: isDark
                              ? TColors.darkBackground
                              : TColors.lightBackground,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: TColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Name
              Text(
                'Adebayo Okafor',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDark
                      ? TColors.textDarkPrimary
                      : TColors.textLightPrimary,
                ),
              ),

              const SizedBox(height: 4),

              // Region
              Text(
                'Lagos State · Nigeria',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? TColors.textDarkTertiary
                      : TColors.textLightTertiary,
                ),
              ),

              const SizedBox(height: 12),

              // Voter ID chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: TColors.secondary.withOpacity(0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 13,
                      color: TColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'VOTER ID:  VS-NG-2024-084731',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: TColors.secondary,
                      ),
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

  // ─────────────────────────────────────────────────────────────
  // 2. IDENTITY INTEGRITY BAND
  // ─────────────────────────────────────────────────────────────

  Widget _buildIdentityBand() {
    return FadeTransition(
      opacity: _anims.identityFade,
      child: SlideTransition(
        position: _anims.identitySlide,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TColors.darkCard : TColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? TColors.darkBorder : TColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AccentTag(label: 'IDENTITY'),
                  const SizedBox(width: 8),
                  Text(
                    'Integrity Score',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? TColors.textDarkPrimary
                          : TColors.textLightPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Score pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.success.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: TColors.success.withOpacity(0.4),
                      ),
                    ),
                    child: const Text(
                      '98 / 100',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: TColors.success,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _IntegrityPill(
                    icon: Icons.fingerprint_rounded,
                    label: 'Biometric',
                    ok: true,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _IntegrityPill(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                    ok: true,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _IntegrityPill(
                    icon: Icons.location_on_outlined,
                    label: 'Region',
                    ok: true,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _IntegrityPill(
                    icon: Icons.lock_outline_rounded,
                    label: 'ZK Proof',
                    ok: true,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Score bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.98,
                  minHeight: 4,
                  backgroundColor: isDark
                      ? TColors.darkBorder
                      : TColors.lightBorder,
                  valueColor: const AlwaysStoppedAnimation(TColors.success),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 12, color: TColors.success),
                  const SizedBox(width: 5),
                  Text(
                    'Zero-Knowledge identity proof active',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: TColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Refresh',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: TColors.secondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: TColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. ACTIVITY STATS
  // ─────────────────────────────────────────────────────────────

  Widget _buildActivityStats() {
    return FadeTransition(
      opacity: _anims.statsFade,
      child: SlideTransition(
        position: _anims.statsSlide,
        child: Row(
          children: [
            _StatCard(
              value: '12',
              label: 'Votes Cast',
              icon: Icons.how_to_vote_outlined,
              isDark: isDark,
            ),
            const SizedBox(width: 10),
            _StatCard(
              value: '7',
              label: 'Elections',
              icon: Icons.bar_chart_rounded,
              isDark: isDark,
            ),
            const SizedBox(width: 10),
            _StatCard(
              value: '4',
              label: 'Day Streak',
              icon: Icons.local_fire_department_outlined,
              accent: TColors.accent,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 4. WALLET CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildWalletCard() {
    return FadeTransition(
      opacity: _anims.walletFade,
      child: SlideTransition(
        position: _anims.walletSlide,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: TColors.institutionalGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TColors.secondary.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: TColors.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AccentTag(label: 'WALLET', light: true),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.secondary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: TColors.secondary.withOpacity(0.4),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: TColors.success),
                        SizedBox(width: 5),
                        Text(
                          'CONNECTED',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: TColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Balance
              const Text(
                '142.30 USDT',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: TColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '≈ \$142.30 USD',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: TColors.white.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 16),
              // Address row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TColors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Text(
                      '0x4e3A...b72F',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: TColors.white.withOpacity(0.7),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Clipboard.setData(
                        const ClipboardData(text: '0x4e3Aabcdef1234567890b72F'),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: TColors.secondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Last deduction note
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 12,
                    color: TColors.white.withOpacity(0.45),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Last deduction: −1.00 USDT · Lagos Gov. 2024',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: TColors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                children: [
                  _WalletActionBtn(
                    label: 'Top Up',
                    icon: Icons.add_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _WalletActionBtn(
                    label: 'History',
                    icon: Icons.history_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _WalletActionBtn(
                    label: 'Disconnect',
                    icon: Icons.link_off_rounded,
                    onTap: () {},
                    danger: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 5. VOTING HISTORY TILE
  // ─────────────────────────────────────────────────────────────

  Widget _buildHistoryTile(_VoteRecord r) {
    return FadeTransition(
      opacity: _anims.listFade,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? TColors.darkCard : TColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? TColors.darkBorder : TColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Election type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TColors.secondary.withOpacity(0.25)),
              ),
              child: Icon(r.icon, size: 18, color: TColors.secondary),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.election,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? TColors.textDarkPrimary
                          : TColors.textLightPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    r.date,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: isDark
                          ? TColors.textDarkTertiary
                          : TColors.textLightTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: r.verified
                        ? TColors.success.withOpacity(0.12)
                        : TColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: r.verified
                          ? TColors.success.withOpacity(0.35)
                          : TColors.warning.withOpacity(0.35),
                    ),
                  ),
                  child: Text(
                    r.verified ? 'Verified' : 'Pending',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: r.verified ? TColors.success : TColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Receipt link
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 10,
                      color: TColors.secondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Receipt',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: TColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 6. SETTINGS GROUP
  // ─────────────────────────────────────────────────────────────

  Widget _buildSettingsGroup() {
    return FadeTransition(
      opacity: _anims.listFade,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? TColors.darkCard : TColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? TColors.darkBorder : TColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            _SettingsToggleRow(
              icon: Icons.notifications_outlined,
              label: 'Election Notifications',
              sublabel: 'Alerts for upcoming & results',
              value: _notificationsOn,
              isDark: isDark,
              onChanged: (v) => setState(() => _notificationsOn = v),
            ),
            _Divider(isDark: isDark),
            _SettingsToggleRow(
              icon: Icons.fingerprint_rounded,
              label: 'Biometric Lock',
              sublabel: 'Require face/finger before voting',
              value: _biometricLock,
              isDark: isDark,
              onChanged: (v) => setState(() => _biometricLock = v),
            ),
            _Divider(isDark: isDark),
            _SettingsToggleRow(
              icon: Icons.visibility_off_outlined,
              label: 'Anonymous Mode',
              sublabel: 'Hide your identity in global feed',
              value: _anonymousMode,
              isDark: isDark,
              onChanged: (v) => setState(() => _anonymousMode = v),
            ),
            _Divider(isDark: isDark),
            _SettingsNavRow(
              icon: Icons.language_rounded,
              label: 'Region & Language',
              isDark: isDark,
              onTap: () {},
            ),
            _Divider(isDark: isDark),
            _SettingsNavRow(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy & Data',
              isDark: isDark,
              onTap: () {},
            ),
            _Divider(isDark: isDark),
            _SettingsNavRow(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              isDark: isDark,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 7. DANGER ZONE
  // ─────────────────────────────────────────────────────────────

  Widget _buildDangerZone() {
    return FadeTransition(
      opacity: _anims.listFade,
      child: Column(
        children: [
          // Sign out
          GestureDetector(
            onTap: () => _showLogoutSheet(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: isDark ? TColors.darkCard : TColors.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? TColors.darkBorder : TColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: TColors.error,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Revoke identity — secondary danger
          GestureDetector(
            onTap: () => _showRevokeSheet(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: TColors.error.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TColors.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.no_accounts_outlined,
                    size: 16,
                    color: TColors.error,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Revoke Identity & Delete Account',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'VoteSecure v1.0.0 · Built on Ethereum L2\nPowered by ZK identity + AI verification',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: isDark
                  ? TColors.textDarkTertiary
                  : TColors.textLightTertiary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION LABEL HELPER
  // ─────────────────────────────────────────────────────────────

  Widget _buildSectionLabel({required String tag, required String title}) {
    return FadeTransition(
      opacity: _anims.statsFade,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: TColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: TColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: isDark
                  ? TColors.textDarkPrimary
                  : TColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BOTTOM SHEETS
  // ─────────────────────────────────────────────────────────────

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        title: 'Sign Out?',
        body:
            'Your wallet and biometric bindings will remain intact. '
            'You can sign back in at any time.',
        confirmLabel: 'Sign Out',
        isDark: isDark,
        onConfirm: () => Navigator.pop(context),
        danger: true,
      ),
    );
  }

  void _showRevokeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        title: 'Revoke Identity?',
        body:
            'This will permanently remove your DID, biometric bindings, '
            'and on-chain voting record association. '
            'This action is irreversible.',
        confirmLabel: 'Revoke & Delete',
        isDark: isDark,
        onConfirm: () => Navigator.pop(context),
        danger: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ANIMATION BUNDLE
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileScreenAnimations {
  final AnimationController entranceController;
  final AnimationController shimmerController;
  final AnimationController pulseController;

  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;
  late final Animation<double> identityFade;
  late final Animation<Offset> identitySlide;
  late final Animation<double> statsFade;
  late final Animation<Offset> statsSlide;
  late final Animation<double> walletFade;
  late final Animation<Offset> walletSlide;
  late final Animation<double> listFade;
  late final Animation<double> pulseAnim;

  _ProfileScreenAnimations({
    required this.entranceController,
    required this.shimmerController,
    required this.pulseController,
  }) {
    headerFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    headerSlide = Tween(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entranceController,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
          ),
        );

    identityFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.15, 0.50, curve: Curves.easeOut),
    );
    identitySlide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entranceController,
            curve: const Interval(0.15, 0.50, curve: Curves.easeOut),
          ),
        );

    statsFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.25, 0.60, curve: Curves.easeOut),
    );
    statsSlide = Tween(begin: const Offset(0, 0.10), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.25, 0.60, curve: Curves.easeOut),
      ),
    );

    walletFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.35, 0.70, curve: Curves.easeOut),
    );
    walletSlide = Tween(begin: const Offset(0, 0.10), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.35, 0.70, curve: Curves.easeOut),
      ),
    );

    listFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );

    pulseAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class _VoteRecord {
  final String election;
  final String date;
  final bool verified;
  final IconData icon;

  const _VoteRecord({
    required this.election,
    required this.date,
    required this.verified,
    required this.icon,
  });
}

final _votingHistory = [
  const _VoteRecord(
    election: 'Lagos State Governorship 2024',
    date: 'Mar 18, 2024  ·  Tx: 0xA3f…',
    verified: true,
    icon: Icons.how_to_vote_rounded,
  ),
  const _VoteRecord(
    election: 'University of Lagos SU Elections',
    date: 'Jan 5, 2024  ·  Tx: 0xC7b…',
    verified: true,
    icon: Icons.school_outlined,
  ),
  const _VoteRecord(
    election: 'Ikeja LGA Community Representative',
    date: 'Nov 22, 2023  ·  Tx: 0xD9e…',
    verified: true,
    icon: Icons.location_city_outlined,
  ),
  const _VoteRecord(
    election: 'National Assembly Runoff 2023',
    date: 'Oct 1, 2023  ·  Tx: 0xB2a…',
    verified: false,
    icon: Icons.account_balance_outlined,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          icon,
          size: 16,
          color: isDark
              ? TColors.textDarkSecondary
              : TColors.textLightSecondary,
        ),
      ),
    );
  }
}

class _AccentTag extends StatelessWidget {
  final String label;
  final bool light;

  const _AccentTag({required this.label, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: light ? TColors.secondary.withOpacity(0.2) : TColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: TColors.secondary,
        ),
      ),
    );
  }
}

class _IntegrityPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool ok;
  final bool isDark;

  const _IntegrityPill({
    required this.icon,
    required this.label,
    required this.ok,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = ok ? TColors.success : TColors.error;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isDark;
  final Color? accent;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? TColors.secondary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? TColors.darkCard : TColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? TColors.darkBorder : TColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? TColors.textDarkPrimary
                    : TColors.textLightPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? TColors.textDarkTertiary
                    : TColors.textLightTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _WalletActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: danger
                ? TColors.error.withOpacity(0.14)
                : TColors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: danger
                  ? TColors.error.withOpacity(0.35)
                  : TColors.white.withOpacity(0.15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: danger ? TColors.error : TColors.white,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: danger ? TColors.error : TColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: TColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? TColors.textDarkPrimary
                        : TColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: isDark
                        ? TColors.textDarkTertiary
                        : TColors.textLightTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: TColors.secondary,
            activeTrackColor: TColors.primary,
            inactiveThumbColor: isDark
                ? TColors.textDarkTertiary
                : TColors.textLightTertiary,
            inactiveTrackColor: isDark
                ? TColors.darkBorder
                : TColors.lightBorder,
          ),
        ],
      ),
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsNavRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: TColors.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? TColors.textDarkPrimary
                      : TColors.textLightPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark
                  ? TColors.textDarkTertiary
                  : TColors.textLightTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? TColors.darkBorder : TColors.lightBorder,
      indent: 16,
      endIndent: 16,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONFIRM BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmSheet extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final bool isDark;
  final VoidCallback onConfirm;
  final bool danger;

  const _ConfirmSheet({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.isDark,
    required this.onConfirm,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 36),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkCard : TColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? TColors.darkBorder : TColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkBorder : TColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(
            danger ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 38,
            color: danger ? TColors.error : TColors.secondary,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? TColors.textDarkPrimary
                  : TColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.6,
              color: isDark
                  ? TColors.textDarkSecondary
                  : TColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? TColors.darkElevated
                          : TColors.lightElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? TColors.darkBorder
                            : TColors.lightBorder,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? TColors.textDarkSecondary
                            : TColors.textLightSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: danger ? TColors.error : TColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      confirmLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColors.white,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
//  DART HELPER (lerpDouble without dart:ui import conflict)
// ─────────────────────────────────────────────────────────────────────────────

double? lerpDouble(num a, num b, double t) {
  return a + (b - a) * t;
}
