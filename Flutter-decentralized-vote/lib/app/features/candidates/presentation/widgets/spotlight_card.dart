import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'candidate_models.dart';
import 'candidate_atomic_widgets.dart';
import 'package:flutter_frontend_vote/app/features/home/presentation/widgets/accent_tag.dart';

class SpotlightCard extends StatelessWidget {
  final CandidateData candidate;
  final Animation<double> spotlightFade;
  final Animation<Offset> spotlightSlide;
  final Animation<double> spotlightScale;
  final Animation<double> spotlightGlow;
  final VoidCallback onTap;

  const SpotlightCard({
    super.key,
    required this.candidate,
    required this.spotlightFade,
    required this.spotlightSlide,
    required this.spotlightScale,
    required this.spotlightGlow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: spotlightFade,
      child: SlideTransition(
        position: spotlightSlide,
        child: ScaleTransition(
          scale: spotlightScale,
          child: AnimatedBuilder(
            animation: spotlightGlow,
            builder: (_, __) => Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: RadialGlowPainter(
                      color: TColors.primary,
                      opacity: 0.12 + 0.16 * spotlightGlow.value,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D2A1E), Color(0xFF12112A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: TColors.secondary.withOpacity(
                        0.25 + 0.12 * spotlightGlow.value,
                      ),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TColors.primary.withOpacity(
                          0.25 + 0.12 * spotlightGlow.value,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AccentTag(label: 'SPOTLIGHT · ${candidate.level}'),
                          const Spacer(),
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CustomPaint(painter: MiniLogoPainter()),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'VERIFIED',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: TColors.secondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CandidateAvatar(
                            initials: candidate.initials,
                            size: 48,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidate.name,
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSerif',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: (THelperFunctions.isDarkMode(context)
                                        ? TColors.white
                                        : TColors.black),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    PartyBadge(
                                      code: candidate.partyCode,
                                      color: candidate.partyColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        candidate.election,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10.5,
                                          color:
                                              (THelperFunctions.isDarkMode(
                                                context,
                                              )
                                              ? TColors.textDarkTertiary
                                              : TColors.textLightTertiary),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 10,
                                      color:
                                          (THelperFunctions.isDarkMode(context)
                                          ? TColors.textDarkTertiary
                                          : TColors.textLightTertiary),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      candidate.region,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10.5,
                                        color:
                                            (THelperFunctions.isDarkMode(
                                              context,
                                            )
                                            ? TColors.textDarkTertiary
                                            : TColors.textLightTertiary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: 32,
                        height: 1.2,
                        color: TColors.secondary,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 95,
                            height: 95,
                            child: AnimatedBuilder(
                              animation: spotlightFade,
                              builder: (_, __) => CustomPaint(
                                painter: SkillRadarPainter(
                                  scores: candidate.radarScores,
                                  progress: spotlightFade.value,
                                  fillColor: TColors.primary.withOpacity(0.35),
                                  strokeColor: TColors.secondary,
                                  gridColor:
                                      (THelperFunctions.isDarkMode(context)
                                      ? TColors.darkBorder
                                      : TColors.lightBorder),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...radarLabels.asMap().entries.map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: TColors.secondary
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          e.value,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9.5,
                                            color:
                                                (THelperFunctions.isDarkMode(
                                                  context,
                                                )
                                                ? TColors.textDarkTertiary
                                                : TColors.textLightTertiary),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${(candidate.radarScores[e.key] * 100).round()}',
                                          style: const TextStyle(
                                            fontFamily: 'IBMPlexMono',
                                            fontSize: 9.5,
                                            color: TColors.secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      'Approval',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 8.5,
                                        color:
                                            (THelperFunctions.isDarkMode(
                                              context,
                                            )
                                            ? TColors.textDarkTertiary
                                            : TColors.textLightTertiary),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${candidate.approvalPct}%',
                                      style: const TextStyle(
                                        fontFamily: 'IBMPlexMono',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: TColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(
                                      begin: 0,
                                      end: candidate.approvalPct / 100,
                                    ),
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.easeOut,
                                    builder: (_, v, __) =>
                                        LinearProgressIndicator(
                                          value: v,
                                          backgroundColor:
                                              (THelperFunctions.isDarkMode(
                                                context,
                                              )
                                              ? TColors.darkBorder
                                              : TColors.lightBorder),
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                TColors.secondary,
                                              ),
                                          minHeight: 3,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'MANIFESTO MILESTONES',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8.5,
                                  color: (THelperFunctions.isDarkMode(context)
                                      ? TColors.textDarkTertiary
                                      : TColors.textLightTertiary),
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${candidate.milestonesAchieved}/${candidate.milestonesTotal} achieved',
                                style: const TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 8.5,
                                  color: TColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AnimatedBuilder(
                            animation: spotlightFade,
                            builder: (_, __) => SizedBox(
                              height: 34,
                              child: CustomPaint(
                                painter: MilestonePainter(
                                  total: candidate.milestonesTotal,
                                  achieved: candidate.milestonesAchieved,
                                  progress: spotlightFade.value,
                                  activeColor: TColors.secondary,
                                  inactiveColor:
                                      (THelperFunctions.isDarkMode(context)
                                      ? TColors.darkBorder
                                      : TColors.lightBorder),
                                  labels: candidate.milestoneLabels,
                                ),
                                size: Size.infinite,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          SpotlightMetric(
                            icon: Icons.forum_outlined,
                            value: '${candidate.forumQuestions}',
                            label: 'Questions',
                          ),
                          const SizedBox(width: 12),
                          SpotlightMetric(
                            icon: Icons.thumb_up_outlined,
                            value: '${candidate.approvalPct}%',
                            label: 'Approval',
                          ),
                          const SizedBox(width: 12),
                          SpotlightMetric(
                            icon: Icons.how_to_reg_outlined,
                            value: '${(candidate.voteShare * 100).round()}%',
                            label: 'Vote Share',
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.accent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: TColors.accent.withOpacity(
                                      0.25 + 0.15 * spotlightGlow.value,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Full Profile',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: (THelperFunctions.isDarkMode(context)
                                      ? TColors.white
                                      : TColors.black),
                                ),
                              ),
                            ),
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
