import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

enum SToastType { success, error, warning, info }

/// Modern, compact overlay toast that sits just below the status bar.
class SToast {
  SToast._();

  static OverlayEntry? _current;

  /// Show a small pill toast just below the notch.
  static void show(
    BuildContext context, {
    required String message,
    SToastType type = SToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    final topPad = MediaQuery.of(context).padding.top;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SToastWidget(
        message: message,
        type: type,

        topPad: topPad,
        duration: duration,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  /// Alias kept for backward compat — same modern toast.
  static void showCustom(
    BuildContext context, {
    required String message,
    SToastType type = SToastType.info,
    Duration duration = const Duration(seconds: 3),
    dynamic gravity,
  }) {
    show(context, message: message, type: type, duration: duration);
  }
}

// ── Private animated toast widget ──────────────────────────────────────────

class _SToastWidget extends StatefulWidget {
  final String message;
  final SToastType type;
  final double topPad;
  final Duration duration;
  final VoidCallback onDismiss;

  const _SToastWidget({
    required this.message,
    required this.type,
    required this.topPad,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_SToastWidget> createState() => _SToastWidgetState();
}

class _SToastWidgetState extends State<_SToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() async {
    await _ctrl.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final (icon, accent) = _resolveStyle(widget.type);

    return Positioned(
      top: widget.topPad + TSizes.sm,
      left: TSizes.md,
      right: TSizes.md,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onVerticalDragEnd: (_) => _dismiss(),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - (TSizes.md * 2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? TColors.darkCard : TColors.lightCard,
                  borderRadius: BorderRadius.circular(TSizes.radiusMd),
                  border: Border.all(
                    color: isDark ? TColors.darkBorder : TColors.lightBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: accent, size: 14),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: isDark
                              ? TColors.textDarkPrimary
                              : TColors.textLightPrimary,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static (IconData, Color) _resolveStyle(SToastType type) {
    return switch (type) {
      SToastType.success => (Icons.check_circle_rounded, TColors.success),
      SToastType.error => (Icons.error_rounded, TColors.error),
      SToastType.warning => (Icons.warning_rounded, TColors.warning),
      SToastType.info => (Icons.info_rounded, TColors.primary),
    };
  }
}
