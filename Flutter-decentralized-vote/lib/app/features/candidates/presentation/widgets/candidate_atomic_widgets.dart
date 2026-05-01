import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'candidate_models.dart';

class CandidateAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const CandidateAvatar({
    super.key,
    required this.initials,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3D2E), Color(0xFF1A1A40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: TColors.secondary.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'IBMPlexSerif',
            fontSize: size * 0.28,
            fontWeight: FontWeight.w700,
            color: TColors.secondary,
          ),
        ),
      ),
    );
  }
}

class PartyBadge extends StatelessWidget {
  final String code;
  final Color color;
  const PartyBadge({super.key, required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(TSizes.radiusXs),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class FollowButton extends StatefulWidget {
  final bool isFollowed;
  final VoidCallback onTap;
  const FollowButton({
    super.key,
    required this.isFollowed,
    required this.onTap,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _bounceAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
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
        widget.onTap();
        _bounceCtrl.forward(from: 0);
      },
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (_, __) => Transform.scale(
          scale: _bounceAnim.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isFollowed
                  ? TColors.secondary.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(TSizes.radiusSm),
              border: Border.all(
                color: widget.isFollowed
                    ? TColors.secondary.withOpacity(0.5)
                    : (isDark
                          ? TColors.darkBorder
                          : TColors.lightBorder),
              ),
            ),
            child: Text(
              widget.isFollowed ? 'Following' : 'Follow',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.isFollowed
                    ? TColors.secondary
                    : (isDark
                          ? TColors.textDarkTertiary
                          : TColors.textLightTertiary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SpotlightMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const SpotlightMetric({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Icon(icon, size: TSizes.iconXs, color: TColors.secondary),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: TColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            color: (isDark
                ? TColors.textDarkTertiary
                : TColors.textLightTertiary),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Row(
      children: [
        Container(width: 3, height: 14, color: TColors.secondary),
        const SizedBox(width: TSizes.sm),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'IBMPlexSerif',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: (isDark
                ? TColors.white
                : TColors.black),
          ),
        ),
      ],
    );
  }
}

class StatsGrid extends StatelessWidget {
  final CandidateData candidate;
  const StatsGrid({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final stats = [
      ('Vote Share', '${(candidate.voteShare * 100).round()}%'),
      ('Approval', '${candidate.approvalPct}%'),
      ('Forum Q', '${candidate.forumQuestions}'),
      (
        'Milestones',
        '${candidate.milestonesAchieved}/${candidate.milestonesTotal}',
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      children: stats
          .map(
            (s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: (isDark
                    ? TColors.darkCard
                    : TColors.lightCard),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isDark
                      ? TColors.darkBorder
                      : TColors.lightBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s.$2,
                    style: TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: (isDark
                          ? TColors.white
                          : TColors.black),
                    ),
                  ),
                  Text(
                    s.$1,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: (isDark
                          ? TColors.textDarkTertiary
                          : TColors.textLightTertiary),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class SheetTabBar extends StatelessWidget {
  final List<String> tabs;
  final int current;
  final void Function(int) onTap;

  const SheetTabBar({
    super.key,
    required this.tabs,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: (isDark
                ? TColors.darkBorder
                : TColors.lightBorder),
          ),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final on = current == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(e.key),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    e.value,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                      color: on
                          ? TColors.secondary
                          : (isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: on ? 20 : 0,
                    height: 2,
                    color: TColors.secondary,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
