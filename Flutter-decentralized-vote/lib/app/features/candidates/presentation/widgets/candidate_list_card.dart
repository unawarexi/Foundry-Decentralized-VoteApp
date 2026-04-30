import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'candidate_models.dart';
import 'candidate_atomic_widgets.dart';

class CandidateListCard extends StatefulWidget {
  final CandidateData data;
  final int index;
  final Animation<double> listAnim;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  const CandidateListCard({
    super.key,
    required this.data,
    required this.index,
    required this.listAnim,
    required this.pulseAnim,
    required this.onTap,
  });

  @override
  State<CandidateListCard> createState() => _CandidateListCardState();
}

class _CandidateListCardState extends State<CandidateListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  bool _followed = false;

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
    final stagger = CurvedAnimation(
      parent: widget.listAnim,
      curve: Interval(
        (widget.index * 0.05).clamp(0.0, 0.6),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (THelperFunctions.isDarkMode(context)
                  ? TColors.darkCard
                  : TColors.lightCard),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: d.isFollowed || _followed
                    ? TColors.secondary.withOpacity(0.35)
                    : (THelperFunctions.isDarkMode(context)
                          ? TColors.darkBorder
                          : TColors.lightBorder),
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CandidateAvatar(initials: d.initials, size: 42),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              d.name,
                              style: TextStyle(
                                fontFamily: 'IBMPlexSerif',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: (THelperFunctions.isDarkMode(context)
                                    ? TColors.white
                                    : TColors.black),
                              ),
                            ),
                          ),
                          if (d.isVerified)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CustomPaint(painter: MiniLogoPainter()),
                            ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          PartyBadge(code: d.partyCode, color: d.partyColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              d.election,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9.5,
                                color: (THelperFunctions.isDarkMode(context)
                                    ? TColors.textDarkTertiary
                                    : TColors.textLightTertiary),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0,
                                  end: d.approvalPct / 100,
                                ),
                                duration: Duration(
                                  milliseconds: 600 + widget.index * 80,
                                ),
                                curve: Curves.easeOut,
                                builder: (_, v, __) => LinearProgressIndicator(
                                  value: v,
                                  backgroundColor:
                                      (THelperFunctions.isDarkMode(context)
                                      ? TColors.darkBorder
                                      : TColors.lightBorder),
                                  valueColor: const AlwaysStoppedAnimation(
                                    TColors.secondary,
                                  ),
                                  minHeight: 3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${d.approvalPct}%',
                            style: const TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: TColors.secondary,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.forum_outlined,
                                size: 10,
                                color: (THelperFunctions.isDarkMode(context)
                                    ? TColors.textDarkTertiary
                                    : TColors.textLightTertiary),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${d.forumQuestions}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9.5,
                                  color: (THelperFunctions.isDarkMode(context)
                                      ? TColors.textDarkTertiary
                                      : TColors.textLightTertiary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        d.manifestoSnippet,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.5,
                          color: (THelperFunctions.isDarkMode(context)
                              ? TColors.textDarkSecondary
                              : TColors.textLightSecondary),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 10,
                            color: (THelperFunctions.isDarkMode(context)
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            d.region,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9.5,
                              color: (THelperFunctions.isDarkMode(context)
                                  ? TColors.textDarkTertiary
                                  : TColors.textLightTertiary),
                            ),
                          ),
                          const Spacer(),
                          FollowButton(
                            isFollowed: d.isFollowed || _followed,
                            onTap: () => setState(() => _followed = !_followed),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
