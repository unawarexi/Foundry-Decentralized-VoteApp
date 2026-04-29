import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class QuickActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color borderColor;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.borderColor,
  });

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    // ScaleTransition on tap — TweenSequence 1.0→0.93→1.0
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _pressScale,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.borderColor),
            ),
            child: Column(
              children: [
                Icon(widget.icon, color: TColors.secondary, size: 20),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: isDark ? TColors.textDarkSecondary : TColors.textLightPrimary,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
