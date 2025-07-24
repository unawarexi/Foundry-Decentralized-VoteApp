import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';


class TAnimations {
  TAnimations._();

  // Animation Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Animation Curves
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve quickCurve = Curves.easeOutQuart;
}

// 1. Fade Transition Animation
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginOpacity;
  final double endOpacity;
  final Duration delay;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = TAnimations.normal,
    this.curve = TAnimations.smoothCurve,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
    this.delay = Duration.zero,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.beginOpacity,
      end: widget.endOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: widget.child);
      },
    );
  }
}

// 2. Slide Animation
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;
  final Offset endOffset;
  final Duration delay;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.duration = TAnimations.normal,
    this.curve = TAnimations.smoothCurve,
    this.beginOffset = const Offset(0, 1),
    this.endOffset = Offset.zero,
    this.delay = Duration.zero,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SlideTransition(position: _animation, child: widget.child);
      },
    );
  }
}

// 3. Scale Animation with Bounce
class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;
  final Duration delay;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = TAnimations.normal,
    this.curve = TAnimations.bounceCurve,
    this.beginScale = 0.0,
    this.endScale = 1.0,
    this.delay = Duration.zero,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: widget.child);
      },
    );
  }
}

// 4. Gradient Animation for Web3 Elements
class GradientAnimation extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientAnimation({
    super.key,
    required this.child,
    this.colors = const [TColors.primaryBlue, TColors.primaryPurple],
    this.duration = const Duration(seconds: 3),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  State<GradientAnimation> createState() => _GradientAnimationState();
}

class _GradientAnimationState extends State<GradientAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(
                  widget.colors[0],
                  widget.colors[1],
                  _animation.value,
                )!,
                Color.lerp(
                  widget.colors[1],
                  widget.colors[0],
                  _animation.value,
                )!,
              ],
              begin: widget.begin,
              end: widget.end,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

// 5. Pulse Animation
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: widget.child);
      },
    );
  }
}

// 6. Shimmer Loading Animation
class ShimmerAnimation extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerAnimation({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1.0, 0.0),
              end: Alignment(_animation.value, 0.0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// 7. Voting Card Animation
class VotingCardAnimation extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final Duration duration;

  const VotingCardAnimation({
    super.key,
    required this.child,
    this.isSelected = false,
    this.duration = TAnimations.normal,
  });

  @override
  State<VotingCardAnimation> createState() => _VotingCardAnimationState();
}

class _VotingCardAnimationState extends State<VotingCardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: TAnimations.smoothCurve),
    );
    _opacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: TAnimations.smoothCurve),
    );
  }

  @override
  void didUpdateWidget(VotingCardAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: TColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// 8. Staggered List Animation
class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final Axis scrollDirection;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.duration = TAnimations.normal,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = TAnimations.smoothCurve,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation> {
  @override
  Widget build(BuildContext context) {
    return widget.scrollDirection == Axis.vertical
        ? Column(
            children: widget.children.asMap().entries.map((entry) {
              return SlideInAnimation(
                delay: Duration(
                  milliseconds: entry.key * widget.staggerDelay.inMilliseconds,
                ),
                duration: widget.duration,
                curve: widget.curve,
                beginOffset: const Offset(0, 0.5),
                child: FadeInAnimation(
                  delay: Duration(
                    milliseconds:
                        entry.key * widget.staggerDelay.inMilliseconds,
                  ),
                  duration: widget.duration,
                  child: entry.value,
                ),
              );
            }).toList(),
          )
        : Row(
            children: widget.children.asMap().entries.map((entry) {
              return SlideInAnimation(
                delay: Duration(
                  milliseconds: entry.key * widget.staggerDelay.inMilliseconds,
                ),
                duration: widget.duration,
                curve: widget.curve,
                beginOffset: const Offset(0.5, 0),
                child: FadeInAnimation(
                  delay: Duration(
                    milliseconds:
                        entry.key * widget.staggerDelay.inMilliseconds,
                  ),
                  duration: widget.duration,
                  child: entry.value,
                ),
              );
            }).toList(),
          );
  }
}

// 9. Blockchain Transaction Animation
class BlockchainAnimation extends StatefulWidget {
  final Widget child;
  final bool isProcessing;

  const BlockchainAnimation({
    super.key,
    required this.child,
    this.isProcessing = false,
  });

  @override
  State<BlockchainAnimation> createState() => _BlockchainAnimationState();
}

class _BlockchainAnimationState extends State<BlockchainAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void didUpdateWidget(BlockchainAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProcessing != oldWidget.isProcessing) {
      if (widget.isProcessing) {
        _pulseController.repeat(reverse: true);
        _rotationController.repeat();
      } else {
        _pulseController.stop();
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isProcessing ? _pulseAnimation.value : 1.0,
          child: Transform.rotate(
            angle: widget.isProcessing
                ? _rotationAnimation.value * 2 * 3.14159
                : 0,
            child: Container(
              decoration: widget.isProcessing
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: TColors.blockchain.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    )
                  : null,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// 10. Success/Error Animation
class StatusAnimation extends StatefulWidget {
  final Widget child;
  final bool isSuccess;
  final bool isError;
  final Duration duration;

  const StatusAnimation({
    super.key,
    required this.child,
    this.isSuccess = false,
    this.isError = false,
    this.duration = TAnimations.slow,
  });

  @override
  State<StatusAnimation> createState() => _StatusAnimationState();
}

class _StatusAnimationState extends State<StatusAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: TAnimations.bounceCurve),
    );
  }

  @override
  void didUpdateWidget(StatusAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSuccess || widget.isError) {
      _colorAnimation = ColorTween(
        begin: Colors.transparent,
        end: widget.isSuccess
            ? TColors.success.withOpacity(0.2)
            : TColors.error.withOpacity(0.2),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller.forward().then((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _controller.reverse();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
