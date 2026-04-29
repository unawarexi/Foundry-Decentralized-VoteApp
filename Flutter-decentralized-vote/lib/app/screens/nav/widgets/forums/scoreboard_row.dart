import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'data_models.dart';
import 'painters.dart';

class ScoreboardRow extends StatelessWidget {
  final ScoreboardCandidate candidate;
  final int index;
  final Animation<double> entranceAnim;
  final Animation<double> pulseAnim;

  const ScoreboardRow({
    super.key,
    required this.candidate,
    required this.index,
    required this.entranceAnim,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final c = candidate;
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 11,
              color: index == 0 ? TColors.secondary : TColors.textDarkTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: const LinearGradient(
              colors: [Color(0xFF0B3D2E), Color(0xFF1A1A40)],
            ),
            border: Border.all(color: TColors.secondary.withOpacity(0.35)),
          ),
          child: Center(
            child: Text(
              c.initials,
              style: const TextStyle(
                fontFamily: 'IBMPlexSerif',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: TColors.secondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            c.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: TColors.textDarkPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: c.responseScore),
                duration: Duration(milliseconds: 600 + index * 100),
                curve: Curves.easeOut,
                builder: (_, v, __) => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: v,
                        backgroundColor: TColors.darkBorder,
                        valueColor: AlwaysStoppedAnimation(
                          c.responseScore > 0.7
                              ? TColors.success
                              : c.responseScore > 0.4
                              ? TColors.warning
                              : TColors.error,
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(c.responseScore * 100).round()}%',
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
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 46,
          height: 10,
          child: CustomPaint(
            painter: HeatmapPainter(
              values: c.activityDots,
              activeColor: TColors.secondary,
              inactiveColor: TColors.darkBorder,
            ),
          ),
        ),
      ],
    );
  }
}
