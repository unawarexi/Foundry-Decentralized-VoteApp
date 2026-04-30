import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Reusable animation presets for screens.
//  Each preset bundles a controller with its
//  driven animations as a single disposable unit.
// ─────────────────────────────────────────────

/// Sheet / panel that slides up and fades in.
/// Used by: Login bottom sheet, any modal-style reveal.
class SheetRevealAnim {
  late final AnimationController controller;
  late final Animation<Offset> slide;
  late final Animation<double> fade;

  SheetRevealAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 800),
    Offset beginOffset = const Offset(0, 0.15),
    Curve slideCurve = Curves.easeOutCubic,
    double fadeEnd = 0.7,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    slide = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: slideCurve),
    );
    fade = CurvedAnimation(
      parent: controller,
      curve: Interval(0.0, fadeEnd, curve: Curves.easeOut),
    );
  }

  void forward() => controller.forward();
  void dispose() => controller.dispose();
}

/// Brand emblem entrance: scale-up + fade-in + subtle rotation.
/// Used by: Splash screen emblem.
class BrandRevealAnim {
  late final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> fade;
  late final Animation<double> rotation;

  BrandRevealAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 900),
    double scaleBegin = 0.3,
    double rotationBegin = -0.05,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    scale = Tween<double>(begin: scaleBegin, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );
    fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    rotation = Tween<double>(begin: rotationBegin, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
  }

  void forward() => controller.forward();
  void dispose() => controller.dispose();
}

/// Content that slides up and fades in simultaneously.
/// Used by: Splash logo text, onboarding content transitions.
class SlideUpFadeAnim {
  late final AnimationController controller;
  late final Animation<double> fade;
  late final Animation<Offset> slide;

  SlideUpFadeAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 700),
    Offset beginOffset = const Offset(0, 0.4),
    Curve slideCurve = Curves.easeOutCubic,
    Curve fadeCurve = Curves.easeOut,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: fadeCurve),
    );
    slide = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: slideCurve),
    );
  }

  void forward() => controller.forward();
  void reset() => controller.reset();
  void dispose() => controller.dispose();
}

/// Ambient glow pulse (0 → 1 ease-in-out).
/// Used by: Splash glow ring behind emblem.
class GlowPulseAnim {
  late final AnimationController controller;
  late final Animation<double> value;

  GlowPulseAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1800),
    Curve curve = Curves.easeInOut,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    value = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  void forward() => controller.forward();
  void dispose() => controller.dispose();
}

/// Simple fade (0 → 1).
/// Used by: Splash tagline, onboarding content fade.
class FadeInAnim {
  late final AnimationController controller;
  late final Animation<double> fade;

  FadeInAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  void forward() => controller.forward();
  void reset() => controller.reset();
  void dispose() => controller.dispose();
}

/// Screen exit: fade-out + slight scale-up.
/// Used by: Splash screen exit transition.
class ExitAnim {
  late final AnimationController controller;
  late final Animation<double> fade;
  late final Animation<double> scale;

  ExitAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 400),
    double scaleEnd = 1.1,
    Curve curve = Curves.easeIn,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    fade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
    scale = Tween<double>(begin: 1.0, end: scaleEnd).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  Future<void> forward() => controller.forward().orCancel.catchError((_) {});
  void dispose() => controller.dispose();
}

/// Continuously expanding ring that fades out (repeats).
/// Used by: Splash screen concentric pulse rings.
class RingPulseAnim {
  late final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> opacity;

  RingPulseAnim({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 2400),
    double scaleEnd = 2.5,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    scale = Tween<double>(begin: 0.6, end: scaleEnd).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );
  }

  void repeat() => controller.repeat();
  void dispose() => controller.dispose();
}

/// Staggered cascade: N items fade+slide in sequence.
/// Returns per-item animations driven by a single controller.
class StaggeredCascadeAnim {
  late final AnimationController controller;
  final List<Animation<double>> fades = [];
  final List<Animation<Offset>> slides;

  StaggeredCascadeAnim({
    required TickerProvider vsync,
    required int itemCount,
    Duration totalDuration = const Duration(milliseconds: 1200),
    Offset beginOffset = const Offset(0, 0.3),
  }) : slides = [] {
    controller = AnimationController(vsync: vsync, duration: totalDuration);
    final segmentLength = 1.0 / itemCount;

    for (int i = 0; i < itemCount; i++) {
      final start = i * segmentLength * 0.7; // overlap windows
      final end = (start + segmentLength).clamp(0.0, 1.0);
      fades.add(Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Interval(start, end, curve: Curves.easeOut)),
      ));
      slides.add(Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      ));
    }
  }

  void forward() => controller.forward();
  void dispose() => controller.dispose();
}

// ─────────────────────────────────────────────────────────────────────────────
//  SPECIFIC SCREEN ORCHESTRATORS
// ─────────────────────────────────────────────────────────────────────────────

/// Orchestrates the complex multi-stage animation for the Splash Screen.
class SplashOrchestrator {
  final TickerProvider vsync;
  final VoidCallback onComplete;

  late final AnimationController backgroundController;
  late final AnimationController logoController;
  late final AnimationController textController;
  late final AnimationController shimmerController;
  late final AnimationController gridController;
  late final AnimationController exitController;

  late final Animation<double> bgAnimation;
  late final Animation<double> logoScale;
  late final Animation<double> logoOpacity;
  late final Animation<double> logoRotate;
  late final Animation<double> ringScale;
  late final Animation<double> ringOpacity;
  late final Animation<double> appNameOpacity;
  late final Animation<Offset> appNameSlide;
  late final Animation<double> dividerWidth;
  late final Animation<double> taglineOpacity;
  late final Animation<Offset> taglineSlide;
  late final Animation<double> shimmerPosition;
  late final Animation<double> gridOpacity;
  late final Animation<double> exitScale;
  late final Animation<double> exitOpacity;

  SplashOrchestrator({required this.vsync, required this.onComplete}) {
    _buildControllers();
    _buildAnimations();
  }

  void _buildControllers() {
    backgroundController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1200));
    logoController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1400));
    textController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1000));
    shimmerController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1800));
    gridController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 2000));
    exitController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 600));
  }

  void _buildAnimations() {
    bgAnimation = CurvedAnimation(parent: backgroundController, curve: Curves.easeOut);

    logoScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.08).chain(CurveTween(curve: Curves.easeOut)), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(logoController);

    logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: logoController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    logoRotate = Tween(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(parent: logoController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    ringScale = Tween(begin: 0.8, end: 2.2).animate(
      CurvedAnimation(parent: logoController, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    ringOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(parent: logoController, curve: const Interval(0.4, 1.0)));

    appNameOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: textController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    appNameSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: textController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    dividerWidth = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: textController, curve: const Interval(0.3, 0.65, curve: Curves.easeOut)),
    );

    taglineOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: textController, curve: const Interval(0.55, 1.0, curve: Curves.easeOut)),
    );
    taglineSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: textController, curve: const Interval(0.55, 1.0, curve: Curves.easeOut)),
    );

    shimmerPosition = Tween(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: shimmerController, curve: Curves.easeInOut),
    );

    gridOpacity = Tween(begin: 0.0, end: 0.06).animate(
      CurvedAnimation(parent: gridController, curve: Curves.easeIn),
    );

    exitScale = Tween(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: exitController, curve: Curves.easeIn));
    exitOpacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: exitController, curve: Curves.easeIn));
  }

  Listenable get combinedListenable => Listenable.merge([
        backgroundController,
        logoController,
        textController,
        shimmerController,
        gridController,
        exitController,
      ]);

  Future<void> startSequence() async {
    backgroundController.forward();
    gridController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    logoController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    textController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    shimmerController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    await exitController.forward();
    onComplete();
  }

  void dispose() {
    backgroundController.dispose();
    logoController.dispose();
    textController.dispose();
    shimmerController.dispose();
    gridController.dispose();
    exitController.dispose();
  }
}

/// Orchestrates animations for the Onboarding Screen.
class OnboardingOrchestrator {
  final TickerProvider vsync;
  final int slideCount;

  late final List<AnimationController> slideControllers;
  late final List<Animation<double>> slideOpacity;
  late final List<Animation<Offset>> slideContentSlide;
  late final List<Animation<double>> slideIllustrationScale;

  late final AnimationController ctaPulseController;
  late final Animation<double> ctaPulseAnim;

  OnboardingOrchestrator({required this.vsync, required this.slideCount}) {
    _buildControllers();
    _buildAnimations();
  }

  void _buildControllers() {
    slideControllers = List.generate(
      slideCount,
      (i) => AnimationController(vsync: vsync, duration: const Duration(milliseconds: 700)),
    );
    ctaPulseController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1500));
  }

  void _buildAnimations() {
    slideOpacity = slideControllers
        .map((c) => Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    slideContentSlide = slideControllers
        .map((c) => Tween(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();

    slideIllustrationScale = slideControllers
        .map((c) => Tween(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();

    ctaPulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: ctaPulseController, curve: Curves.easeInOut),
    );
    ctaPulseController.repeat(reverse: true);
  }

  void animateSlide(int index) {
    if (index >= 0 && index < slideControllers.length) {
      slideControllers[index].forward(from: 0);
    }
  }

  void dispose() {
    for (final c in slideControllers) {
      c.dispose();
    }
    ctaPulseController.dispose();
  }
}

/// Orchestrates animations for the Login Screen.
class LoginOrchestrator {
  final TickerProvider vsync;

  late final AnimationController entranceController;
  late final AnimationController shimmerController;
  late final AnimationController pulseController;

  late final Animation<double> bgAnim;
  late final Animation<double> logoAnim;
  late final Animation<double> headerAnim;
  late final Animation<Offset> headerSlide;
  late final Animation<double> formAnim;
  late final Animation<Offset> formSlide;
  late final Animation<double> footerAnim;
  late final Animation<double> shimmerPos;
  late final Animation<double> pulseAnim;

  LoginOrchestrator({required this.vsync}) {
    _buildControllers();
    _buildAnimations();
  }

  void _buildControllers() {
    entranceController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1400));
    shimmerController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 2000));
    pulseController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1800));
  }

  void _buildAnimations() {
    bgAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    logoAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.1, 0.5, curve: Curves.easeOut));
    headerAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.3, 0.65, curve: Curves.easeOut));
    headerSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: entranceController, curve: const Interval(0.3, 0.65, curve: Curves.easeOut)),
    );
    formAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.5, 0.85, curve: Curves.easeOut));
    formSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: entranceController, curve: const Interval(0.5, 0.85, curve: Curves.easeOut)),
    );
    footerAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.75, 1.0, curve: Curves.easeOut));
    shimmerPos = Tween(begin: -0.3, end: 1.3).animate(CurvedAnimation(parent: shimmerController, curve: Curves.easeInOut));
    pulseAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: pulseController, curve: Curves.easeInOut));

    shimmerController.repeat();
    pulseController.repeat(reverse: true);
  }

  void forward() => entranceController.forward();

  void dispose() {
    entranceController.dispose();
    shimmerController.dispose();
    pulseController.dispose();
  }
}

/// Orchestrates animations for the Sign Up Screen.
class SignUpOrchestrator {
  final TickerProvider vsync;

  late final AnimationController entranceController;
  late final AnimationController shimmerController;
  late final AnimationController bgPulseController;

  late final Animation<double> bgAnim;
  late final Animation<double> logoAnim;
  late final Animation<double> headerAnim;
  late final Animation<Offset> headerSlide;
  late final Animation<double> stepAnim;
  late final Animation<Offset> stepSlide;
  late final Animation<double> formAnim;
  late final Animation<Offset> formSlide;
  late final Animation<double> footerAnim;
  late final Animation<double> shimmerPos;

  SignUpOrchestrator({required this.vsync}) {
    _buildControllers();
    _buildAnimations();
  }

  void _buildControllers() {
    entranceController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1500));
    shimmerController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 2200));
    bgPulseController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 3000));
  }

  void _buildAnimations() {
    bgAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    logoAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.1, 0.5, curve: Curves.easeOut));
    headerAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.25, 0.6, curve: Curves.easeOut));
    headerSlide = Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: entranceController, curve: const Interval(0.25, 0.6, curve: Curves.easeOut)),
    );
    stepAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut));
    stepSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: entranceController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );
    formAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.55, 0.85, curve: Curves.easeOut));
    formSlide = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: entranceController, curve: const Interval(0.55, 0.85, curve: Curves.easeOut)),
    );
    footerAnim = CurvedAnimation(parent: entranceController, curve: const Interval(0.8, 1.0, curve: Curves.easeOut));
    shimmerPos = Tween(begin: -0.3, end: 1.3).animate(CurvedAnimation(parent: shimmerController, curve: Curves.easeInOut));

    shimmerController.repeat();
    bgPulseController.repeat(reverse: true);
  }

  void forward() => entranceController.forward();

  void dispose() {
    entranceController.dispose();
    shimmerController.dispose();
    bgPulseController.dispose();
  }
}

/// Staggered entrance animation builder for HomeScreen and similar screens.
/// Extracted from vote_screen.dart for DRYness and reusability.
class HomeScreenEntranceAnimations {
  final AnimationController entranceController;
  final AnimationController shimmerController;
  final AnimationController pulseController;

  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;
  late final Animation<double> identityCardFade;
  late final Animation<Offset> identityCardSlide;
  late final Animation<double> statsRowFade;
  late final Animation<Offset> statsRowSlide;
  late final Animation<double> sectionFade;
  late final Animation<double> cardsFade;
  late final Animation<Offset> cardsSlide;
  late final Animation<double> globalFade;
  late final Animation<Offset> globalSlide;
  late final Animation<double> shimmerPos;
  late final Animation<double> pulseAnim;

  HomeScreenEntranceAnimations({
    required this.entranceController,
    required this.shimmerController,
    required this.pulseController,
  }) {
    // Header (top greeting + logo bar)
    headerFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    headerSlide = Tween(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Identity card (voter status card)
    identityCardFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    );
    identityCardSlide = Tween(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    ));

    // Stats row (3 quick-stat chips)
    statsRowFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
    );
    statsRowSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
    ));

    // Section label + election cards
    sectionFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );
    cardsFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    );
    cardsSlide = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    ));

    // Global feed strip
    globalFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );
    globalSlide = Tween(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Gold shimmer
    shimmerPos = Tween(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: shimmerController, curve: Curves.easeInOut),
    );

    // Live pulse
    pulseAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }
}

/// Staggered entrance animation builder for ElectionsScreen.
class ElectionsScreenAnimations {
  final AnimationController entranceController;
  final AnimationController shimmerController;
  final AnimationController pulseController;
  final AnimationController searchController;

  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;
  late final Animation<double> filterFade;
  late final Animation<double> heroFade;
  late final Animation<Offset> heroSlide;
  late final Animation<double> listFade;
  late final Animation<Offset> listSlide;
  late final Animation<double> shimmerPos;
  late final Animation<double> pulseAnim;
  late final Animation<double> searchExpandAnim;

  ElectionsScreenAnimations({
    required this.entranceController,
    required this.shimmerController,
    required this.pulseController,
    required this.searchController,
  }) {
    headerFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    headerSlide = Tween(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    filterFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.1, 0.45, curve: Curves.easeOut),
    );

    heroFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    heroSlide = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    listFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );
    listSlide = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
      ),
    );

    shimmerPos = Tween(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: shimmerController, curve: Curves.easeInOut),
    );

    pulseAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    searchExpandAnim = CurvedAnimation(
      parent: searchController,
      curve: Curves.easeOut,
    );
  }
}

/// Staggered entrance animation builder for CandidatesScreen.
class CandidatesScreenAnimations {
  final AnimationController entranceController;
  final AnimationController shimmerController;
  final AnimationController pulseController;
  final AnimationController viewToggleController;
  final AnimationController spotlightController;

  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;

  late final Animation<double> spotlightFade;
  late final Animation<Offset> spotlightSlide;
  late final Animation<double> spotlightScale;

  late final Animation<double> filterRowFade;
  late final Animation<double> listFade;
  late final Animation<Offset> listSlide;

  late final Animation<double> shimmerPos;
  late final Animation<double> pulseAnim;
  late final Animation<double> spotlightGlow;

  CandidatesScreenAnimations({
    required this.entranceController,
    required this.shimmerController,
    required this.pulseController,
    required this.viewToggleController,
    required this.spotlightController,
  }) {
    headerFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    headerSlide = Tween(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    filterRowFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.1, 0.45, curve: Curves.easeOut),
    );

    spotlightFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    );
    spotlightSlide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );
    spotlightScale = Tween(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );

    listFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
    );
    listSlide = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
      ),
    );

    shimmerPos = Tween(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: shimmerController, curve: Curves.easeInOut),
    );

    pulseAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    spotlightGlow = Tween(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: spotlightController, curve: Curves.easeInOut),
    );
  }
}

/// Staggered entrance animation builder for ForumScreen.
class ForumScreenAnimations {
  final AnimationController entranceController;
  final AnimationController shimmerController;
  final AnimationController pulseController;
  final AnimationController fabController;

  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;
  late final Animation<double> scoreboardFade;
  late final Animation<Offset> scoreboardSlide;
  late final Animation<double> listFade;
  late final Animation<Offset> listSlide;
  late final Animation<double> fabEntrance;
  late final Animation<double> fabFloat;
  late final Animation<double> shimmerPos;
  late final Animation<double> pulseAnim;

  ForumScreenAnimations({
    required this.entranceController,
    required this.shimmerController,
    required this.pulseController,
    required this.fabController,
  }) {
    headerFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    headerSlide = Tween(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    scoreboardFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
    );
    scoreboardSlide = Tween(begin: const Offset(0, 0.14), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );

    listFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
    );
    listSlide = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
      ),
    );

    fabEntrance = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
    );

    fabFloat = Tween(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: fabController, curve: Curves.easeInOut),
    );

    shimmerPos = Tween(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: shimmerController, curve: Curves.easeInOut),
    );

    pulseAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }
}

/// Staggered entrance animation builder for ProfileScreen.
/// Staggered entrance animation builder for ProfileScreen.
class ProfileScreenAnimations {
  final AnimationController entranceController;
  final AnimationController shimmerController;
  final AnimationController pulseController;
  final AnimationController heroGlowController;
  final AnimationController zkRingController;

  late final Animation<double> heroFade;
  late final Animation<Offset> heroSlide;
  late final Animation<double> heroScale;

  late final Animation<double> verifyFade;
  late final Animation<Offset> verifySlide;

  late final Animation<double> statsFade;
  late final Animation<Offset> statsSlide;

  late final Animation<double> contentFade;
  late final Animation<Offset> contentSlide;

  late final Animation<double> shimmerPos;
  late final Animation<double> pulseAnim;
  late final Animation<double> heroGlow;
  late final Animation<double> zkRotation;

  ProfileScreenAnimations({
    required this.entranceController,
    required this.shimmerController,
    required this.pulseController,
    required this.heroGlowController,
    required this.zkRingController,
  }) {
    // Hero profile header
    heroFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    heroSlide = Tween(begin: const Offset(0, -0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    heroScale = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Verification strip & Voter ID Card
    verifyFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
    );
    verifySlide = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );

    // Stats row
    statsFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
    );
    statsSlide = Tween(begin: const Offset(0, 0.14), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );

    // Content sections (history, candidates, wallet, settings)
    contentFade = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
    );
    contentSlide = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
      ),
    );

    // Shimmer sweep
    shimmerPos = Tween(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: shimmerController, curve: Curves.easeInOut),
    );

    // Live status pulse
    pulseAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    // Hero ambient glow (spotlight effect)
    heroGlow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: heroGlowController, curve: Curves.easeInOut),
    );

    // ZK ring continuous rotation
    zkRotation = Tween(begin: 0.0, end: 2 * 3.141592653589793).animate(
      CurvedAnimation(parent: zkRingController, curve: Curves.linear),
    );
  }
}
