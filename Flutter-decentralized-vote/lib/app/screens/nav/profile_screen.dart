import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/store/theme_provider.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

// Modular Widget Imports
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/hero_header.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/verification_strip.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/voter_id_card.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/profile_stats_row.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/activity_waveform.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/vote_history_tile.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/data_models.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/accent_tag.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/security_toggle_row.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/sign_out_button.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/wallet_row.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/divider_line.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/section_label.dart';
import 'package:flutter_frontend_vote/app/screens/nav/widgets/profile/preference_selection_row.dart';

/*
  PROFILE SCREEN — VoteSecure Institutional Design
  ─────────────────────────────────────────────────────────────────────────────
  The "Profile" screen serves as the digital sovereign identity hub. 
  It utilizes the established design language:
  1. Staggered Entrance: Tri-animation entrance (fade/slide/scale).
  2. Modular Slats: Content is broken into horizontal "slats" (slivers).
  3. Interactive ZK Proofs: Rotating ZK status rings and verified badges.
  4. Institutional Texture: Custom grid backgrounds and embossed card patterns.
*/

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _heroGlowController;
  late AnimationController _zkRingController;

  // Animation Bundles
  late ProfileScreenAnimations _animations;

  // Scroll logic
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // UI State
  bool _walletExpanded = false;
  bool _securityExpanded = false;
  bool _preferencesExpanded = false;
  bool _privacyExpanded = false;
  bool _notificationsExpanded = false;

  @override
  void initState() {
    super.initState();

    // 1. Initialize Entrance Animation (1100ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // 2. Initialize Shimmer Sweep (One-shot, 2000ms)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 3. Initialize Global Pulse (Indicator breathing, 1600ms)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // 4. Initialize Hero Ambient Glow (Spotlight drift, 3000ms)
    _heroGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // 5. Initialize ZK Status Ring (8s/revolution)
    _zkRingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Initialize the specialized animation bundle
    _animations = ProfileScreenAnimations(
      entranceController: _entranceController,
      shimmerController: _shimmerController,
      pulseController: _pulseController,
      heroGlowController: _heroGlowController,
      zkRingController: _zkRingController,
    );

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    _runEntrance();
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
    _heroGlowController.dispose();
    _zkRingController.dispose();
    _scrollController.dispose();
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
          _heroGlowController,
          _zkRingController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              _buildBackground(isDark),
              // 1. Institutional Grid Background
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: AuthGridPainter(
                  color: TColors.secondary.withOpacity(isDark ? 0.04 : 0.12),
                ),
              ),

              // Decorative Hex Rings
              Positioned(
                top: -50,
                right: -50,
                child: Opacity(
                  opacity: isDark ? 0.05 : 0.18,
                  child: CustomPaint(
                    size: const Size(230, 230),
                    painter: HexRingPainter(
                      color: isDark
                          ? TColors.secondary
                          : TColors.primary.withOpacity(0.45),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -60,
                child: Opacity(
                  opacity: isDark ? 0.04 : 0.15,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: HexRingPainter(
                      color: isDark
                          ? TColors.secondary
                          : TColors.primary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),

              _buildBody(context, isDark),
              _buildShimmer(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0B1A12),
                  TColors.darkBackground,
                  const Color(0xFF0A0A16),
                ]
              : [
                  const Color(0xFFE5F0ED),
                  TColors.lightBackground,
                  const Color(0xFFE9E9F4),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
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
              width: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    TColors.secondary.withOpacity(isDark ? 0.05 : 0.1),
                    TColors.secondary.withOpacity(isDark ? 0.12 : 0.22),
                    TColors.secondary.withOpacity(isDark ? 0.05 : 0.1),
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
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Sticky Header (Blends with Status Bar)
        SliverAppBar(
          pinned: true,
          primary: false,
          toolbarHeight: 0,
          expandedHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
        ),

        // ── Hero profile header
        SliverToBoxAdapter(
          child: ProfileHeroHeader(
            heroFade: _animations.heroFade,
            heroSlide: _animations.heroSlide,
            heroScale: _animations.heroScale,
            heroGlow: _animations.heroGlow,
            zkRotation: _animations.zkRotation,
            pulseAnim: _animations.pulseAnim,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // ── Identity verification strip
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VerificationStrip(
              verifyFade: _animations.verifyFade,
              verifySlide: _animations.verifySlide,
              pulseAnim: _animations.pulseAnim,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // ── Voter ID card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VoterIDCard(
              verifyFade: _animations.verifyFade,
              verifySlide: _animations.verifySlide,
              pulseAnim: _animations.pulseAnim,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // ── Civic stats row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProfileStatsRow(
              statsFade: _animations.statsFade,
              statsSlide: _animations.statsSlide,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // ── Civic participation waveform
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ActivityWaveform(contentFade: _animations.contentFade),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // ── Voting history
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionLabel(
              tag: 'VOTE RECORD',
              title: 'Voting History',
              contentFade: _animations.contentFade,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: VoteHistoryTile(
                record: voteHistory[i],
                index: i,
                contentAnim: _animations.contentFade,
              ),
            ),
            childCount: voteHistory.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // ── Followed candidates
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionLabel(
              tag: 'FOLLOWING',
              title: 'Tracked Candidates',
              contentFade: _animations.contentFade,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(child: _buildFollowedCandidates(isDark)),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // ── Expandable sections
        _buildExpandableSliver(
          tag: 'WEB3',
          title: 'Wallet & Tokens',
          icon: Icons.account_balance_wallet_outlined,
          isExpanded: _walletExpanded,
          onToggle: () => setState(() => _walletExpanded = !_walletExpanded),
          child: _buildWalletContent(isDark),
          isDark: isDark,
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        _buildExpandableSliver(
          tag: 'SECURITY',
          title: 'Biometric & Identity',
          icon: Icons.security_outlined,
          isExpanded: _securityExpanded,
          onToggle: () =>
              setState(() => _securityExpanded = !_securityExpanded),
          child: _buildSecurityContent(isDark),
          isDark: isDark,
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        _buildExpandableSliver(
          tag: 'PREFERENCES',
          title: 'App Experience',
          icon: Icons.settings_suggest_outlined,
          isExpanded: _preferencesExpanded,
          onToggle: () =>
              setState(() => _preferencesExpanded = !_preferencesExpanded),
          child: Consumer(
            builder: (context, ref, _) {
              return _buildPreferencesContent(ref, isDark);
            },
          ),
          isDark: isDark,
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        _buildExpandableSliver(
          tag: 'ZK-PROOF',
          title: 'Privacy Settings',
          icon: Icons.shield_outlined,
          isExpanded: _privacyExpanded,
          onToggle: () => setState(() => _privacyExpanded = !_privacyExpanded),
          child: _buildPrivacyContent(isDark),
          isDark: isDark,
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        _buildExpandableSliver(
          tag: 'ALERTS',
          title: 'Notifications',
          icon: Icons.notifications_outlined,
          isExpanded: _notificationsExpanded,
          onToggle: () =>
              setState(() => _notificationsExpanded = !_notificationsExpanded),
          child: _buildNotificationsContent(isDark),
          isDark: isDark,
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // ── App version + about
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildAboutRow(isDark),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // ── Sign out
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FadeTransition(
              opacity: _animations.contentFade,
              child: SignOutButton(contentFade: _animations.contentFade),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ),
  );
}

  Widget _buildExpandableSliver({
    required String tag,
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    required bool isDark,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FadeTransition(
          opacity: _animations.contentFade,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? TColors.darkCard : TColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? TColors.darkBorder : TColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: TColors.secondary, size: 16),
                        const SizedBox(width: 10),
                        AccentTag(label: tag),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSerif',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? TColors.white : TColors.black,
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: isExpanded
                      ? Column(children: [const DividerLine(), child])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowedCandidates(bool isDark) {
    return FadeTransition(
      opacity: _animations.contentFade,
      child: SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: followedCandidates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final c = followedCandidates[i];
            return Container(
              width: 130,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? TColors.darkCard : TColors.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? TColors.darkBorder : TColors.lightBorder,
                ),
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
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CustomPaint(painter: MiniLogoPainter()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.name,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? TColors.textDarkPrimary
                          : TColors.textLightPrimary,
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

  Widget _buildWalletContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          const WalletRow(
            label: 'Connected Wallet',
            value: '0x7f4a...3e12',
            icon: Icons.account_balance_wallet_outlined,
            mono: true,
          ),
          const SizedBox(height: 12),
          const WalletRow(
            label: 'USDT Balance',
            value: '\$24.50',
            icon: Icons.toll_outlined,
          ),
          const SizedBox(height: 12),
          const WalletRow(
            label: 'Votes Paid For',
            value: '2 transactions',
            icon: Icons.receipt_outlined,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkElevated : TColors.lightElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? TColors.darkBorder : TColors.lightBorder,
              ),
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

  Widget _buildSecurityContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: const [
          SecurityToggleRow(
            label: 'Biometric Login',
            subtitle: 'Fingerprint or Face ID required',
            icon: Icons.fingerprint,
            enabled: true,
          ),
          DividerLine(),
          SecurityToggleRow(
            label: 'Device Binding',
            subtitle: 'This device is the only trusted device',
            icon: Icons.phone_android_outlined,
            enabled: true,
          ),
          DividerLine(),
          SecurityToggleRow(
            label: 'Government DB Sync',
            subtitle: 'Identity verified against NIMC database',
            icon: Icons.verified_user_outlined,
            enabled: true,
          ),
          DividerLine(),
          SecurityToggleRow(
            label: 'Live Face Check',
            subtitle: 'Required before each vote is cast',
            icon: Icons.face_outlined,
            enabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesContent(WidgetRef ref, bool isDark) {
    final currentTheme = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          PreferenceSelectionRow<ThemeMode>(
            label: 'Appearance Mode',
            icon: Icons.palette_outlined,
            options: const [
              PreferenceOption(label: 'System', value: ThemeMode.system),
              PreferenceOption(label: 'Light', value: ThemeMode.light),
              PreferenceOption(label: 'Dark', value: ThemeMode.dark),
            ],
            selectedValue: currentTheme,
            onSelected: (mode) {
              ref.read(themeModeProvider.notifier).setThemeMode(mode);
            },
          ),
          const DividerLine(),
          const SizedBox(height: 4),
          const SecurityToggleRow(
            label: 'AI Copilot',
            subtitle: 'Real-time voting assistance and analysis',
            icon: Icons.auto_awesome_outlined,
            enabled: true,
          ),
          const DividerLine(),
          const SecurityToggleRow(
            label: 'Voice Assistant',
            subtitle: 'Accessibility-first voice navigation',
            icon: Icons.record_voice_over_outlined,
            enabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _zkRingController,
                builder: (_, __) => SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomPaint(
                    painter: ZKProofCirclePainter(
                      rotation: _zkRingController.value * 2 * math.pi,
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
                    Text(
                      'ZK Proof Active',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSerif',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? TColors.white : TColors.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Your vote is private. Your identity is proven without being exposed.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: isDark
                            ? TColors.textDarkTertiary
                            : TColors.textLightTertiary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const DividerLine(),
          const SecurityToggleRow(
            label: 'Anonymous Vote Mode',
            subtitle: 'Hide vote from public ledger (ZK enabled)',
            icon: Icons.visibility_off_outlined,
            enabled: true,
          ),
          const DividerLine(),
          const SecurityToggleRow(
            label: 'Share Civic Score',
            subtitle: 'Allow others to see your participation rate',
            icon: Icons.public_outlined,
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: const [
          SecurityToggleRow(
            label: 'Election Reminders',
            subtitle: '24h before elections in your region',
            icon: Icons.notifications_active_outlined,
            enabled: true,
          ),
          DividerLine(),
          SecurityToggleRow(
            label: 'Candidate Answers',
            subtitle: 'When a candidate responds to your question',
            icon: Icons.comment_outlined,
            enabled: true,
          ),
          DividerLine(),
          SecurityToggleRow(
            label: 'Results Alerts',
            subtitle: 'When elections you voted in conclude',
            icon: Icons.bar_chart_rounded,
            enabled: true,
          ),
          DividerLine(),
          SecurityToggleRow(
            label: 'Fraud Alerts',
            subtitle: 'AI-detected anomalies in your region',
            icon: Icons.warning_amber_outlined,
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(bool isDark) {
    return FadeTransition(
      opacity: _animations.contentFade,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CustomPaint(painter: MiniLogoPainter()),
          ),
          const SizedBox(width: 8),
          Text(
            'VoteSecure v1.0.0',
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 11,
              color: isDark
                  ? TColors.textDarkTertiary
                  : TColors.textLightTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '·',
            style: TextStyle(
              color: isDark ? TColors.darkBorder : TColors.lightBorder,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Terms',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: isDark
                  ? TColors.textDarkTertiary
                  : TColors.textLightTertiary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '·',
            style: TextStyle(
              color: isDark ? TColors.darkBorder : TColors.lightBorder,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Privacy',
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
    );
  }
}
