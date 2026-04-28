import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'candidate_models.dart';
import 'candidate_atomic_widgets.dart';

class ProfileTab extends StatelessWidget {
  final CandidateData candidate;
  final ScrollController ctrl;
  const ProfileTab({super.key, required this.candidate, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = candidate;
    return ListView(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: SkillRadarPainter(
                scores: c.radarScores,
                progress: 1.0,
                fillColor: THelperFunctions.isDarkMode(context)
                    ? TColors.primary.withOpacity(0.35)
                    : TColors.secondary.withOpacity(0.4),
                strokeColor: THelperFunctions.isDarkMode(context)
                    ? TColors.secondary
                    : TColors.primary,
                gridColor: THelperFunctions.isDarkMode(context)
                    ? TColors.darkBorder
                    : TColors.textLightTertiary.withOpacity(0.35),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        const SectionTitle(title: 'Approval Rating History'),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: CustomPaint(
            painter: WaveformPainter(
              values: c.approvalHistory,
              activeColor: TColors.secondary,
              inactiveColor: (THelperFunctions.isDarkMode(context)
                  ? TColors.darkBorder
                  : TColors.lightBorder),
            ),
            size: const Size(double.infinity, 48),
          ),
        ),

        const SizedBox(height: 20),

        const SectionTitle(title: 'Biography'),
        const SizedBox(height: 8),
        Text(
          c.bio,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: (THelperFunctions.isDarkMode(context)
                ? TColors.textDarkSecondary
                : TColors.textLightSecondary),
            height: 1.65,
          ),
        ),

        const SizedBox(height: 20),

        const SectionTitle(title: 'Key Metrics'),
        const SizedBox(height: 12),
        StatsGrid(candidate: c),
      ],
    );
  }
}

class ManifestoTab extends StatelessWidget {
  final CandidateData candidate;
  final ScrollController ctrl;
  const ManifestoTab({super.key, required this.candidate, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        const SectionTitle(title: 'Manifesto Milestones'),
        const SizedBox(height: 12),
        ...candidate.manifestoPoints.asMap().entries.map((e) {
          final i = e.key;
          final point = e.value;
          final achieved = i < candidate.milestonesAchieved;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: achieved
                        ? TColors.secondary.withOpacity(0.15)
                        : (THelperFunctions.isDarkMode(context)
                              ? TColors.darkElevated
                              : TColors.lightElevated),
                    border: Border.all(
                      color: achieved
                          ? TColors.secondary
                          : (THelperFunctions.isDarkMode(context)
                                ? TColors.darkBorder
                                : TColors.lightBorder),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: achieved
                        ? const Icon(
                            Icons.check,
                            color: TColors.secondary,
                            size: 14,
                          )
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: (THelperFunctions.isDarkMode(context)
                                  ? TColors.textDarkTertiary
                                  : TColors.textLightTertiary),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.title,
                        style: TextStyle(
                          fontFamily: 'IBMPlexSerif',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: achieved
                              ? (THelperFunctions.isDarkMode(context)
                                    ? TColors.white
                                    : TColors.black)
                              : (THelperFunctions.isDarkMode(context)
                                    ? TColors.textDarkSecondary
                                    : TColors.textLightSecondary),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        point.description,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: (THelperFunctions.isDarkMode(context)
                              ? TColors.textDarkTertiary
                              : TColors.textLightTertiary),
                          height: 1.5,
                        ),
                      ),
                      if (achieved) ...[
                        const SizedBox(height: 5),
                        const Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 11,
                              color: TColors.success,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified on-chain',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: TColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class ForumTab extends StatelessWidget {
  final CandidateData candidate;
  final ScrollController ctrl;
  const ForumTab({super.key, required this.candidate, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      itemCount: mockForumQuestions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final q = mockForumQuestions[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (THelperFunctions.isDarkMode(context)
                ? TColors.darkCard
                : TColors.lightCard),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: q.isUnanswered
                  ? TColors.warning.withOpacity(0.28)
                  : (THelperFunctions.isDarkMode(context)
                        ? TColors.darkBorder
                        : TColors.lightBorder),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Q${i + 1}',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 10,
                      color: TColors.secondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (q.isUnanswered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: TColors.warning.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        q.timer,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          color: TColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                q.question,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: (THelperFunctions.isDarkMode(context)
                      ? TColors.textDarkPrimary
                      : TColors.textLightPrimary),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_upward_rounded,
                    size: 12,
                    color: TColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${q.upvotes}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: TColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    q.timePosted,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: (THelperFunctions.isDarkMode(context)
                          ? TColors.textDarkTertiary
                          : TColors.textLightTertiary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class HistoryTab extends StatelessWidget {
  final CandidateData candidate;
  final ScrollController ctrl;
  const HistoryTab({super.key, required this.candidate, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      itemCount: candidate.lifeHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (_, i) {
        final item = candidate.lifeHistory[i];
        final isLast = i == candidate.lifeHistory.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TColors.secondary.withOpacity(0.7),
                    border: Border.all(
                      color: TColors.secondary.withOpacity(0.4),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 52,
                    color: (THelperFunctions.isDarkMode(context)
                        ? TColors.darkBorder
                        : TColors.lightBorder),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.year,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 10,
                        color: TColors.secondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.event,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSerif',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: (THelperFunctions.isDarkMode(context)
                            ? TColors.white
                            : TColors.black),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.detail,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: (THelperFunctions.isDarkMode(context)
                            ? TColors.textDarkTertiary
                            : TColors.textLightTertiary),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
