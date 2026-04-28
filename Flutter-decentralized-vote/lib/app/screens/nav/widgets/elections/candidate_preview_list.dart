import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'elections_data.dart';

class CandidatePreviewList extends StatelessWidget {
  final int candidates;
  const CandidatePreviewList({super.key, required this.candidates});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final items = mockCandidates.take(candidates.clamp(0, 4)).toList();
    return Column(
      children: [
        Divider(height: 1, color: isDark ? TColors.darkBorder : TColors.lightBorder),
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return _CandidateRow(candidate: c, index: i);
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View all candidates →',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: TColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final CandidateData candidate;
  final int index;
  const _CandidateRow({required this.candidate, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  TColors.primary.withOpacity(0.8),
                  TColors.secondaryAlt.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: TColors.secondary.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                candidate.initials,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSerif',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: TColors.secondary,
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
                  candidate.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
                  ),
                ),
                Text(
                  candidate.party,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${candidate.pollPct}%',
                style: const TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TColors.secondary,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: candidate.pollPct / 100),
                    duration: Duration(milliseconds: 500 + index * 100),
                    curve: Curves.easeOut,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      backgroundColor: isDark ? TColors.darkBorder : TColors.lightBorder,
                      valueColor: AlwaysStoppedAnimation(
                        index == 0
                            ? TColors.secondary
                            : (isDark ? TColors.textDarkTertiary : TColors.textLightTertiary).withOpacity(0.5),
                      ),
                      minHeight: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
