import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'candidate_models.dart';
import 'candidate_atomic_widgets.dart';

class CandidateGridCard extends StatefulWidget {
  final CandidateData data;
  final int index;
  final Animation<double> listAnim;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  const CandidateGridCard({
    super.key,
    required this.data,
    required this.index,
    required this.listAnim,
    required this.pulseAnim,
    required this.onTap,
  });

  @override
  State<CandidateGridCard> createState() => _CandidateGridCardState();
}

class _CandidateGridCardState extends State<CandidateGridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
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

    final stagger = CurvedAnimation(
      parent: widget.listAnim,
      curve: Interval(
        (widget.index * 0.06).clamp(0.0, 0.7),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: stagger,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.reverse(),
        onTapUp: (_) {
          _pressCtrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.forward(),
        child: AnimatedBuilder(
          animation: _pressCtrl,
          builder: (_, child) =>
              Transform.scale(scale: _pressCtrl.value, child: child),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (THelperFunctions.isDarkMode(context)
                  ? TColors.darkCard
                  : TColors.lightCard),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (THelperFunctions.isDarkMode(context)
                    ? TColors.darkBorder
                    : TColors.lightBorder),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CandidateAvatar(initials: d.initials, size: 44),

                const SizedBox(height: 8),

                Text(
                  d.name,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSerif',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: (THelperFunctions.isDarkMode(context)
                        ? TColors.white
                        : TColors.black),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 5),

                PartyBadge(code: d.partyCode, color: d.partyColor),

                const SizedBox(height: 6),

                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: d.approvalPct / 100),
                  duration: Duration(milliseconds: 600 + widget.index * 60),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: v,
                          backgroundColor: (THelperFunctions.isDarkMode(context)
                              ? TColors.darkBorder
                              : TColors.lightBorder),
                          valueColor: const AlwaysStoppedAnimation(
                            TColors.secondary,
                          ),
                          minHeight: 2.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.approvalPct}% approval',
                        style: const TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 9,
                          color: TColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Text(
                  d.region,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: (THelperFunctions.isDarkMode(context)
                        ? TColors.textDarkTertiary
                        : TColors.textLightTertiary),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
