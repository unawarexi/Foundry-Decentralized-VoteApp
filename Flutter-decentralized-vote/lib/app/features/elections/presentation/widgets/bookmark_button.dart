import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  const BookmarkButton({super.key, required this.isBookmarked});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late bool _saved;
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _saved = widget.isBookmarked;
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
    final isDark = THelperFunctions.isDarkMode(context);
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
                  : (isDark ? TColors.darkElevated : TColors.lightElevated),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _saved
                    ? TColors.secondary.withOpacity(0.45)
                    : (isDark ? TColors.darkBorder : TColors.lightBorder),
              ),
            ),
            child: Icon(
              _saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _saved
                  ? TColors.secondary
                  : (isDark ? TColors.textDarkTertiary : TColors.textLightTertiary),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
