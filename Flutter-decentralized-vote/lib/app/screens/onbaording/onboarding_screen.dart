import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/onboarding/onboarding_components.dart';
import 'package:flutter_frontend_vote/app/components/splash/splash_components.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart'
    hide MiniLogoPainter;

// ──────────────────────────────────────────────────────────────
// ONBOARDING SCREEN — 5 Slides
// "Modern infrastructure with institutional weight"
// ──────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentPage = 0;
  late final OnboardingOrchestrator _orchestrator;

  static const List<OnboardSlide> _slides = [
    OnboardSlide(
      tag: '01 — IDENTITY',
      headline: 'Your Vote.\nYour Proof.',
      body:
          'Biometric verification fused with government identity databases. '
          'Zero-Knowledge Proofs ensure your identity is confirmed without '
          'ever exposing your personal data.',
      visual: SlideVisual.identity,
      accentLabel: 'ZK-PROOF SECURED',
    ),
    OnboardSlide(
      tag: '02 — REGION LOCK',
      headline: 'Only You.\nOnly Here.',
      body:
          'AI-powered GPS, IP, SIM, and document correlation guarantees '
          'region integrity. No proxy. No bypass. No foreign interference '
          'in your democratic process.',
      visual: SlideVisual.regionLock,
      accentLabel: 'AI REGION DETECTION',
    ),
    OnboardSlide(
      tag: '03 — BLOCKCHAIN',
      headline: 'Every Vote.\nOn-Chain.',
      body:
          'Smart contracts on an EVM-compatible layer record each vote '
          'immutably. A \$1 consensus fee deters spam while the ledger '
          'remains transparent to the world.',
      visual: SlideVisual.blockchain,
      accentLabel: 'EVM SMART CONTRACTS',
    ),
    OnboardSlide(
      tag: '04 — TRANSPARENCY',
      headline: 'Global View.\nNo Secrets.',
      body:
          'Live elections. Real-time participation. Verified results. '
          'Watch any election on Earth unfold in public — candidates, '
          'votes, milestones, manifestos — all verifiable.',
      visual: SlideVisual.transparency,
      accentLabel: 'GLOBAL DASHBOARD',
    ),
    OnboardSlide(
      tag: '05 — GOVERNANCE',
      headline: 'Every Level.\nEvery Voice.',
      body:
          'From school elections to heads of state — VoteSecure supports '
          'every governance layer. Public Q&A forums, candidate accountability '
          'timers, and AI-scored responses keep candidates honest.',
      visual: SlideVisual.governance,
      accentLabel: 'AI GOVERNANCE LAYER',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orchestrator = OnboardingOrchestrator(
      vsync: this,
      slideCount: _slides.length,
    );
    _orchestrator.animateSlide(0);
  }

  void _onPageChanged(int index, _) {
    setState(() => _currentPage = index);
    _orchestrator.animateSlide(index);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _carouselController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToApp();
    }
  }

  void _navigateToApp() {
    context.go('/option');
  }

  @override
  void dispose() {
    _orchestrator.dispose();
    super.dispose();
  }

  // ── Whether to show the grid+decorative pattern for this slide ──
  bool _showLightPattern(bool isDark) {
    // Only for light mode, slides 2–4 (indices 1, 2, 3)
    return !isDark && _currentPage >= 1 && _currentPage <= 4;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLast = _currentPage == _slides.length - 1;
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
      body: Stack(
        children: [
          // ── Gradient backdrop ──
          _buildBackdrop(),

          // ── Dark-mode grid texture ──
          if (isDark)
            Opacity(
              opacity: 0.04,
              child: CustomPaint(
                size: size,
                painter: GridPainter(color: TColors.secondary, spacing: 36.0),
              ),
            ),

          // ── Light-mode AuthGrid + fade (slides 2–4 only) ──
          if (_showLightPattern(isDark)) ...[
            // Grid layer
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: 1.0,
              child: CustomPaint(
                size: size,
                painter: AuthGridPainter(
                  color: TColors.secondary.withOpacity(0.10),
                ),
              ),
            ),
            // Fade gradient over the grid (same style as options screen)
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TColors.lightBackground.withOpacity(0.94),
                    Colors.transparent,
                    TColors.secondary.withOpacity(0.08),
                    Colors.transparent,
                    TColors.lightBackground.withOpacity(0.88),
                  ],
                  stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
                ),
              ),
            ),
            // Decorative swoosh ON TOP of the grid
            Positioned(
              bottom: -40,
              right: -40,
              child: Opacity(
                opacity: 0.06,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: SSwooshPainter(
                    colors: [TColors.secondary, TColors.primary],
                    isDark: false,
                  ),
                ),
              ),
            ),
            // Hex ring accent ON TOP of the grid
            Positioned(
              top: -80,
              right: -80,
              child: Opacity(
                opacity: 0.07,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: HexRingPainter(),
                ),
              ),
            ),
          ],

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(),

                const SizedBox(height: TSizes.sm),

                // Carousel — auto-slide enabled
                Expanded(
                  child: CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: _slides.length,
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: false,
                      onPageChanged: _onPageChanged,
                      scrollPhysics: const BouncingScrollPhysics(),
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 600,
                      ),
                      autoPlayCurve: Curves.easeInOut,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return _buildSlide(index, size);
                    },
                  ),
                ),

                // Bottom controls
                _buildBottomControls(isLast),

                const SizedBox(height: TSizes.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdrop() {
    final isDark = THelperFunctions.isDarkMode(context);
    // Subtly shift gradient tone based on current slide
    final darkColors = [
      [const Color(0xFF060E0A), const Color(0xFF0A0A0A)],
      [const Color(0xFF080810), const Color(0xFF0A0A0A)],
      [const Color(0xFF0A0E06), const Color(0xFF0A0A0A)],
      [const Color(0xFF06080E), const Color(0xFF0A0A0A)],
      [const Color(0xFF0D0A06), const Color(0xFF0A0A0A)],
    ];
    final lightColors = [
      [const Color(0xFFF1F8E9), const Color(0xFFF8F7F4)],
      [const Color(0xFFE8EAF6), const Color(0xFFF8F7F4)],
      [const Color(0xFFF9FBE7), const Color(0xFFF8F7F4)],
      [const Color(0xFFE3F2FD), const Color(0xFFF8F7F4)],
      [const Color(0xFFFFF3E0), const Color(0xFFF8F7F4)],
    ];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? darkColors[_currentPage] : lightColors[_currentPage],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final isDark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.lg,
        vertical: TSizes.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo wordmark
          Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CustomPaint(painter: MiniLogoPainter()),
              ),
              const SizedBox(width: 10),
              Text(
                'VOTESECURE',
                style: TextStyle(
                  fontFamily: 'IBMPlexSerif',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? TColors.white : TColors.primary,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          // Skip
          if (_currentPage < _slides.length - 1)
            GestureDetector(
              onTap: _navigateToApp,
              child: Text(
                'Skip',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: isDark
                      ? TColors.textDarkTertiary
                      : TColors.textLightTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlide(int index, Size size) {
    final slide = _slides[index];
    final isDark = THelperFunctions.isDarkMode(context);
    return AnimatedBuilder(
      animation: _orchestrator.slideControllers[index],
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Illustration
              Expanded(
                flex: 5,
                child: Transform.scale(
                  scale: _orchestrator.slideIllustrationScale[index].value,
                  child: Opacity(
                    opacity: _orchestrator.slideOpacity[index].value,
                    child: SlideIllustration(
                      visual: slide.visual,
                      index: index,
                      animationValue:
                          _orchestrator.slideControllers[index].value,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: TSizes.lg),

              // Text content
              Expanded(
                flex: 4,
                child: FadeTransition(
                  opacity: _orchestrator.slideOpacity[index],
                  child: SlideTransition(
                    position: _orchestrator.slideContentSlide[index],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Accent tag (gold)
                        AccentTag(label: slide.accentLabel),

                        const SizedBox(height: 14),

                        // Headline
                        Text(
                          slide.headline,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSerif',
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: isDark ? TColors.white : TColors.primary,
                            height: 1.15,
                          ),
                        ),

                        const SizedBox(height: TSizes.md),

                        // Gold rule
                        Container(
                          width: 40,
                          height: 2,
                          color: TColors.secondary,
                        ),

                        const SizedBox(height: TSizes.md),

                        // Body
                        Text(
                          slide.body,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: isDark
                                ? TColors.textDarkSecondary
                                : TColors.textLightSecondary,
                            height: 1.65,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(bool isLast) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
      child: Column(
        children: [
          // Smooth page indicator
          AnimatedSmoothIndicator(
            activeIndex: _currentPage,
            count: _slides.length,
            effect: ExpandingDotsEffect(
              activeDotColor: TColors.secondary,
              dotColor: isDark ? TColors.darkBorder : TColors.lightBorder,
              dotHeight: 6,
              dotWidth: 6,
              expansionFactor: 4,
              spacing: 6,
            ),
          ),

          const SizedBox(height: TSizes.sectionSpacing),

          // CTA button
          AnimatedBuilder(
            animation: _orchestrator.ctaPulseController,
            builder: (_, __) {
              return GestureDetector(
                onTap: _next,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: TSizes.buttonHeightLg,
                  decoration: BoxDecoration(
                    color: isLast ? TColors.accent : TColors.primary,
                    borderRadius: BorderRadius.circular(TSizes.radiusSm + 2),
                    border: Border.all(
                      color: isLast
                          ? TColors.accent.withValues(alpha: 0.6)
                          : TColors.secondary.withValues(
                              alpha:
                                  0.2 + 0.3 * _orchestrator.ctaPulseAnim.value,
                            ),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isLast ? TColors.accent : TColors.primary)
                            .withValues(
                              alpha:
                                  0.35 +
                                  0.15 * _orchestrator.ctaPulseAnim.value,
                            ),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? 'Vote' : 'Continue',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TColors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        isLast
                            ? Icons.how_to_vote_rounded
                            : Icons.arrow_forward,
                        color: TColors.white,
                        size: TSizes.iconSm,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
