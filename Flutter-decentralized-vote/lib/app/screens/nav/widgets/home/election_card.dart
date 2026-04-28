import 'package:flutter/material.dart' hide AnimatedBuilder;
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/widgets/spinners.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'accent_tag.dart';
import 'data_models.dart';

/// Horizontal-scrolling election card with tap-to-scale micro-interaction.
class ElectionCard extends StatefulWidget {
  final ElectionData data;
  const ElectionCard({super.key, required this.data});

  @override
  State<ElectionCard> createState() => _ElectionCardState();
}

class _ElectionCardState extends State<ElectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    // ScaleTransition 1.0→0.97 on tap
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
    final d = widget.data;
    final isDark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.forward(),
      child: AnimatedBuilder(
        listenable: _pressCtrl,
        builder: (_, __) => Transform.scale(
          scale: _pressCtrl.value,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkCard : TColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: d.isUrgent
                    ? TColors.accent.withOpacity(0.45)
                    : (isDark ? TColors.darkBorder : TColors.lightBorder),
              ),
              boxShadow: [
                BoxShadow(
                  color: (d.isUrgent ? TColors.accent : TColors.primary)
                      .withOpacity(isDark ? 0.12 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AccentTag(label: d.level),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: d.isUrgent ? TColors.accent : TColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  d.title,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSerif',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? TColors.white : TColors.primary,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  d.region,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: isDark ? TColors.textDarkTertiary : TColors.textLightSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                // Participation progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Participation',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: isDark ? TColors.textDarkTertiary : TColors.textLightSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${d.participation}%',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: TColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: d.participation / 100,
                        backgroundColor: isDark ? TColors.darkBorder : TColors.lightBorder,
                        valueColor: const AlwaysStoppedAnimation(
                          TColors.secondary,
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: isDark ? TColors.textDarkTertiary : TColors.textLightSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      d.timeLeft,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: d.isUrgent
                            ? TColors.accent
                            : (isDark ? TColors.textDarkTertiary : TColors.textLightSecondary),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${d.candidates} candidates',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: isDark ? TColors.textDarkTertiary : TColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
