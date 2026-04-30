import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/features/home/presentation/widgets/accent_tag.dart';
import 'live_badge.dart';
import 'status_chip.dart';
import 'mini_stat.dart';
import 'bookmark_button.dart';
import 'participation_bar.dart';
import 'candidate_preview_list.dart';
import 'elections_data.dart';

class ElectionListCard extends StatefulWidget {
  final ElectionData data;
  final int index;
  final Animation<double> listAnim;
  final Animation<Offset> slideAnim;
  final Animation<double> pulseAnim;

  const ElectionListCard({
    super.key,
    required this.data,
    required this.index,
    required this.listAnim,
    required this.slideAnim,
    required this.pulseAnim,
  });

  @override
  State<ElectionListCard> createState() => _ElectionListCardState();
}

class _ElectionListCardState extends State<ElectionListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
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

    final staggeredFade = CurvedAnimation(
      parent: widget.listAnim,
      curve: Interval(
        (widget.index * 0.06).clamp(0.0, 0.6),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: staggeredFade,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.reverse(),
        onTapUp: (_) {
          _pressCtrl.forward();
          setState(() => _expanded = !_expanded);
        },
        onTapCancel: () => _pressCtrl.forward(),
        child: AnimatedBuilder(
          animation: _pressCtrl,
          builder: (_, child) =>
              Transform.scale(scale: _pressCtrl.value, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isDark ? TColors.darkCard : TColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _statusBorderColor(d.status, widget.pulseAnim.value, isDark),
                width: d.status == ElectionStatus.live ? 1.0 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _statusGlowColor(d.status).withOpacity(isDark ? 0.1 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top row: level tag + status badge + chevron
                      Row(
                        children: [
                          AccentTag(label: d.level),
                          const SizedBox(width: 8),
                          if (d.status == ElectionStatus.live)
                            LiveBadge(
                              pulse: widget.pulseAnim.value,
                              label: 'LIVE',
                            ),
                          if (d.status == ElectionStatus.upcoming)
                            const StatusChip(
                              label: 'UPCOMING',
                              color: TColors.secondary,
                            ),
                          if (d.status == ElectionStatus.closed)
                            StatusChip(
                              label: 'CLOSED',
                              color: isDark
                                  ? TColors.textDarkTertiary
                                  : TColors.textLightTertiary,
                            ),
                          const Spacer(),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
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

                      const SizedBox(height: 10),

                      // ── Election title
                      Text(
                        d.title,
                        style: TextStyle(
                          fontFamily: 'IBMPlexSerif',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? TColors.white : TColors.primary,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ── Region + date row
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 10.5,
                            color: isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            d.region,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: isDark
                                  ? TColors.textDarkTertiary
                                  : TColors.textLightTertiary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.access_time_rounded,
                            size: 10.5,
                            color: d.status == ElectionStatus.live
                                ? TColors.accent
                                : (isDark
                                    ? TColors.textDarkTertiary
                                    : TColors.textLightTertiary),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            d.timeDisplay,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: d.status == ElectionStatus.live
                                  ? TColors.accent
                                  : (isDark
                                      ? TColors.textDarkTertiary
                                      : TColors.textLightTertiary),
                              fontWeight: d.status == ElectionStatus.live
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Participation bar
                      if (d.participation > 0) ...[
                        ParticipationBar(
                          percent: d.participation,
                          entranceAnim: widget.listAnim,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ── Bottom: candidates + fee + bookmark
                      Row(
                        children: [
                          MiniStat(
                            icon: Icons.person_outline_rounded,
                            value: '${d.candidates}',
                            label: 'candidates',
                          ),
                          const SizedBox(width: 14),
                          const MiniStat(
                            icon: Icons.toll_outlined,
                            value: '\$1',
                            label: 'USDT fee',
                          ),
                          const Spacer(),
                          BookmarkButton(isBookmarked: d.isBookmarked),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Expanded: candidate preview list
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: _expanded
                      ? CandidatePreviewList(candidates: d.candidates)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusBorderColor(ElectionStatus s, double pulse, bool isDark) {
    switch (s) {
      case ElectionStatus.live:
        return TColors.accent.withOpacity(0.3 + 0.2 * pulse);
      case ElectionStatus.upcoming:
        return isDark ? TColors.darkBorder : TColors.lightBorder;
      case ElectionStatus.closed:
        return (isDark ? TColors.darkBorder : TColors.lightBorder)
            .withOpacity(0.5);
    }
  }

  Color _statusGlowColor(ElectionStatus s) {
    switch (s) {
      case ElectionStatus.live:
        return TColors.accent;
      case ElectionStatus.upcoming:
        return TColors.secondary;
      case ElectionStatus.closed:
        return Colors.transparent;
    }
  }
}
