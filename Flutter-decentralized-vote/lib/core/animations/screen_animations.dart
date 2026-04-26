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

